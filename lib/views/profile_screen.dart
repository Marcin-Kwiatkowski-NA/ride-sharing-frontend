import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blablafront/core/providers/auth_provider.dart';
import 'package:blablafront/core/models/user.dart';
import 'package:blablafront/routes/app_router.dart';
import 'package:blablafront/views/Bottom_Buttons.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;

        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AppRouter.navigateAndClearStack(context, AppRoutes.login);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            automaticallyImplyLeading: false,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      ProfileImage(pictureUrl: user.pictureUrl),
                      const SizedBox(height: 16),
                      ProfileDetails(user: user),
                      const SizedBox(height: 32),
                      ProfileActions(
                        onLogout: () => _handleLogout(context, authProvider),
                      ),
                    ],
                  ),
                ),
              ),
              const Bottom_Buttons(primary: 3),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleLogout(BuildContext context, AuthProvider authProvider) async {
    await authProvider.signOut();
    if (context.mounted) {
      AppRouter.navigateAndClearStack(context, AppRoutes.login);
    }
  }
}

class ProfileImage extends StatelessWidget {
  final String? pictureUrl;

  const ProfileImage({super.key, this.pictureUrl});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.teal.shade100,
      backgroundImage: pictureUrl != null ? NetworkImage(pictureUrl!) : null,
      onBackgroundImageError: pictureUrl != null
          ? (exception, stackTrace) {}
          : null,
      child: pictureUrl == null
          ? Icon(Icons.person, size: 60, color: Colors.teal.shade700)
          : null,
    );
  }
}

class ProfileDetails extends StatelessWidget {
  final User user;

  const ProfileDetails({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Text(
            user.displayName,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.email, user.email),
          if (user.phoneNumber != null)
            _buildInfoRow(Icons.phone, user.phoneNumber!),
          if (user.isDriver)
            _buildInfoRow(Icons.directions_car, 'Driver'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: Colors.grey.shade700, fontSize: 16)),
        ],
      ),
    );
  }
}

class ProfileActions extends StatelessWidget {
  final VoidCallback onLogout;

  const ProfileActions({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('My rides coming soon!')),
                );
              },
              icon: const Icon(Icons.history),
              label: const Text('My Rides'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
