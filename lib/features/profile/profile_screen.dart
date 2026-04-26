import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:electromart_pro/core/constants/app_constants.dart';
import 'package:electromart_pro/core/providers/auth_provider.dart';
import 'package:electromart_pro/core/providers/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : _buildProfileContent(context, ref, user),
    );
  }

  Widget _buildProfileContent(BuildContext context, WidgetRef ref, user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        children: [
          // Profile Header
          _buildProfileHeader(user),

          const SizedBox(height: AppConstants.paddingLarge),

          // Menu Items
          _buildMenuItem(
            icon: Icons.shopping_bag,
            title: 'My Orders',
            onTap: () => Navigator.of(context).pushNamed('/orders'),
          ),

          _buildMenuItem(
            icon: Icons.location_on,
            title: 'Saved Addresses',
            onTap: () => Navigator.of(context).pushNamed('/addresses'),
          ),

          _buildMenuItem(
            icon: Icons.credit_card,
            title: 'Payment Methods',
            onTap: () => Navigator.of(context).pushNamed('/payment-methods'),
          ),

          _buildMenuItem(
            icon: Icons.favorite,
            title: 'Wishlist',
            onTap: () => Navigator.of(context).pushNamed('/wishlist'),
          ),

          _buildMenuItem(
            icon: Icons.notifications,
            title: 'Notifications',
            onTap: () => Navigator.of(context).pushNamed('/notifications'),
          ),

          _buildMenuItem(
            icon: Icons.share,
            title: 'Refer & Earn',
            onTap: () => _showReferralDialog(context),
          ),

          _buildMenuItem(
            icon: Icons.star,
            title: 'Rate App',
            onTap: () {
              // TODO: Open app store rating
            },
          ),

          _buildMenuItem(
            icon: Icons.help,
            title: 'Help & Support',
            onTap: () => Navigator.of(context).pushNamed('/support'),
          ),

          const Divider(),

          // Settings
          _buildMenuItem(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            trailing: Switch(
              value: ref.watch(themeProvider) == ThemeMode.dark,
              onChanged: (value) {
                ref.read(themeProvider.notifier).setTheme(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
              },
            ),
          ),

          _buildMenuItem(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English',
            onTap: () => _showLanguageDialog(context),
          ),

          const Divider(),

          // Logout
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Logout',
            textColor: Colors.red,
            onTap: () => _showLogoutDialog(context, ref),
          ),

          // App Version
          const SizedBox(height: AppConstants.paddingLarge),
          const Text(
            'Version ${AppConstants.appVersion}',
            style: AppConstants.bodyText2,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Row(
          children: [
            // Profile Avatar
            CircleAvatar(
              radius: 40,
              backgroundImage:
                  user.avatar != null ? NetworkImage(user.avatar!) : null,
              child: user.avatar == null
                  ? Text(
                      user.name?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(fontSize: 24),
                    )
                  : null,
            ),

            const SizedBox(width: AppConstants.paddingMedium),

            // Profile Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name ?? 'User',
                    style: AppConstants.headline2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email ?? '',
                    style: AppConstants.bodyText2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.phone ?? '',
                    style: AppConstants.bodyText2,
                  ),
                ],
              ),
            ),

            // Edit Button
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // TODO: Navigate to edit profile
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showReferralDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refer & Earn'),
        content: const Text(
          'Share your referral code with friends and earn rewards when they make their first purchase!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Share referral code
              Navigator.of(context).pop();
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              title: const Text('Hindi'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              title: const Text('Spanish'),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(currentUserProvider.notifier).signOut();
              Navigator.of(context).pop();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
