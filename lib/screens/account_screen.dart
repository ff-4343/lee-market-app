import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  static const String _storeUrl = 'https://leemarket.ae';

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B00),
        elevation: 0,
        title: const Text('Account',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF6B00), Color(0xFFE55A00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12)
                      ],
                    ),
                    child: const Icon(Icons.person,
                        size: 44, color: Color(0xFFFF6B00)),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Welcome to LEE Market',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Sign in to manage your orders',
                    style:
                        TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () =>
                        _launchUrl('$_storeUrl/account/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFFF6B00),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('Sign In',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Menu sections ──────────────────────────────────────────────────────
            _buildSection('My Orders', [
              _MenuItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'Order History',
                  onTap: () =>
                      _launchUrl('$_storeUrl/account/orders')),
              _MenuItem(
                  icon: Icons.local_shipping_outlined,
                  label: 'Track Orders',
                  onTap: () => _launchUrl('$_storeUrl/account')),
            ]),

            _buildSection('Account', [
              _MenuItem(
                  icon: Icons.person_outline,
                  label: 'Profile',
                  onTap: () => _launchUrl('$_storeUrl/account')),
              _MenuItem(
                  icon: Icons.location_on_outlined,
                  label: 'Addresses',
                  onTap: () =>
                      _launchUrl('$_storeUrl/account/addresses')),
            ]),

            _buildSection('Support', [
              _MenuItem(
                  icon: Icons.help_outline,
                  label: 'Help & FAQ',
                  onTap: () =>
                      _launchUrl('$_storeUrl/pages/faq')),
              _MenuItem(
                  icon: Icons.chat_bubble_outline,
                  label: 'Contact Us',
                  onTap: () =>
                      _launchUrl('$_storeUrl/pages/contact')),
              _MenuItem(
                  icon: Icons.policy_outlined,
                  label: 'Privacy Policy',
                  onTap: () =>
                      _launchUrl('$_storeUrl/policies/privacy-policy')),
              _MenuItem(
                  icon: Icons.article_outlined,
                  label: 'Terms of Service',
                  onTap: () =>
                      _launchUrl('$_storeUrl/policies/terms-of-service')),
            ]),

            // ── App version ──────────────────────────────────────────────────────────
            const SizedBox(height: 24),
            const Text(
              'LEE Market v1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            const Text(
              'leemarket.ae',
              style: TextStyle(
                  color: Color(0xFFFF6B00),
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<_MenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Text(
            title,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
                letterSpacing: 0.5),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04), blurRadius: 8)
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  InkWell(
                    onTap: item.onTap,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Icon(item.icon,
                              color: const Color(0xFFFF6B00), size: 22),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(item.label,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1A1A1A))),
                          ),
                          const Icon(Icons.chevron_right,
                              color: Colors.grey, size: 20),
                        ],
                      ),
                    ),
                  ),
                  if (index < items.length - 1)
                    Divider(
                        height: 1,
                        indent: 52,
                        color: Colors.grey[100]),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _MenuItem(
      {required this.icon, required this.label, required this.onTap});
}
