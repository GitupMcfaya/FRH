import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/repository_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/models.dart';
import '../controllers/users_controller.dart';

class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({super.key});

  @override
  ConsumerState<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersControllerProvider);
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Management',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Manage staff profiles, roles, and account access.',
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                key: const Key('add-user-button'),
                onPressed: () => _showForm(),
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                label: const Text('Add Staff User'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 420,
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'Search name, email, or role',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: users.when(
              loading: () =>
                  const Card(child: Center(child: CircularProgressIndicator())),
              error: (error, _) => Card(child: Center(child: Text('$error'))),
              data: (items) {
                final term = _query.trim().toLowerCase();
                final filtered = items.where((user) {
                  return term.isEmpty ||
                      user.fullName.toLowerCase().contains(term) ||
                      user.email.toLowerCase().contains(term) ||
                      user.role.name.toLowerCase().contains(term);
                }).toList();
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          AppColors.lavender,
                        ),
                        columns: const [
                          DataColumn(label: Text('STAFF MEMBER')),
                          DataColumn(label: Text('EMAIL')),
                          DataColumn(label: Text('ROLE')),
                          DataColumn(label: Text('LAST LOGIN')),
                          DataColumn(label: Text('STATUS')),
                          DataColumn(label: Text('ACTIONS')),
                        ],
                        rows: [
                          for (final user in filtered)
                            DataRow(
                              cells: [
                                DataCell(Text(user.fullName)),
                                DataCell(Text(user.email)),
                                DataCell(Text(_roleLabel(user.role))),
                                DataCell(
                                  Text(
                                    user.lastLoginAt == null
                                        ? 'Never'
                                        : _formatDate(user.lastLoginAt!),
                                  ),
                                ),
                                DataCell(
                                  Text(user.isActive ? 'Active' : 'Inactive'),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: 'Edit ${user.fullName}',
                                        onPressed: () => _showForm(user),
                                        icon: const Icon(Icons.edit_outlined),
                                      ),
                                      Switch(
                                        value: user.isActive,
                                        onChanged: user.id == 'user-admin-001'
                                            ? null
                                            : (value) => ref
                                                  .read(
                                                    usersControllerProvider
                                                        .notifier,
                                                  )
                                                  .setActive(user, value),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showForm([User? user]) async {
    final saved = await showDialog<User>(
      context: context,
      builder: (_) => _UserFormDialog(user: user),
    );
    if (saved != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            user == null ? 'Staff user added.' : 'Staff user updated.',
          ),
        ),
      );
    }
  }
}

class _UserFormDialog extends ConsumerStatefulWidget {
  const _UserFormDialog({this.user});

  final User? user;

  @override
  ConsumerState<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends ConsumerState<_UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late UserRole _role;
  var _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.user?.fullName);
    _email = TextEditingController(text: widget.user?.email);
    _role = widget.user?.role ?? UserRole.receptionist;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.user == null ? 'Add Staff User' : 'Edit Staff User'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email address'),
                validator: (value) => value != null && value.contains('@')
                    ? null
                    : 'Enter a valid email',
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<UserRole>(
                initialValue: _role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: UserRole.values
                    .map(
                      (role) => DropdownMenuItem(
                        value: role,
                        child: Text(_roleLabel(role)),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _role = value!),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: AppColors.danger)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Saving...' : 'Save User'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final existing = widget.user;
    try {
      final saved = await ref
          .read(usersControllerProvider.notifier)
          .save(
            User(
              id: existing?.id ?? '',
              fullName: _name.text.trim(),
              email: _email.text.trim().toLowerCase(),
              role: _role,
              isActive: existing?.isActive ?? true,
              createdAt: existing?.createdAt ?? DateTime.now(),
              lastLoginAt: existing?.lastLoginAt,
            ),
          );
      if (mounted) Navigator.pop(context, saved);
    } on RepositoryException catch (error) {
      setState(() {
        _saving = false;
        _error = error.message;
      });
    }
  }
}

String _roleLabel(UserRole role) => switch (role) {
  UserRole.administrator => 'Administrator',
  UserRole.receptionist => 'Receptionist',
};

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
