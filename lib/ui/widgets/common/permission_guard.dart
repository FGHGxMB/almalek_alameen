// lib/ui/widgets/common/permission_guard.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../data/models/user_model.dart';

class PermissionGuard extends StatelessWidget {
  final bool Function(PermissionsModel) permissionCheck;
  final Widget child;
  final Widget fallback;

  const PermissionGuard({
    Key? key,
    required this.permissionCheck,
    required this.child,
    this.fallback = const SizedBox.shrink(), // الافتراضي: إخفاء العنصر تماماً
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      if (permissionCheck(authState.user.permissions)) {
        return child;
      }
    }
    return fallback;
  }
}