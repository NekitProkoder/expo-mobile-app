import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/exhibitor.dart';

class ParticipantDetailScreen extends StatelessWidget {
  final Exhibitor exhibitor;
  final bool isFavorite;
  final VoidCallback onFavoriteChanged;

  const ParticipantDetailScreen({
    super.key,
    required this.exhibitor,
    required this.isFavorite,
    required this.onFavoriteChanged,
  });

  Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> callPhone(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    await openUrl('tel:$phone');
  }

  Future<void> sendEmail(String? email) async {
    if (email == null || email.isEmpty) return;
    await openUrl('mailto:$email');
  }

  Widget logoWidget() {
    final logoUrl = exhibitor.logoUrl;

    if (logoUrl == null || logoUrl.isEmpty) {
      return const Icon(Icons.store, size: 70, color: Colors.black87);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Image.network(
        logoUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.store, size: 70, color: Colors.black87);
        },
      ),
    );
  }

  Widget headerBlock() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFACA2C),
            Color(0xFFFFE58A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: logoWidget(),
          ),
          const SizedBox(height: 18),
          Text(
            exhibitor.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              height: 1.1,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          if ((exhibitor.category ?? '').isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                exhibitor.category!,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          if ((exhibitor.standNumber ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Стенд ${exhibitor.standNumber}',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget actionButton({
    required IconData icon,
    required String title,
    required VoidCallback? onTap,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.black, size: 20),
        label: Text(
          title,
          style: const TextStyle(color: Colors.black),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget quickActions() {
    final hasWebsite = (exhibitor.website ?? '').isNotEmpty;
    final hasPhone = (exhibitor.phone ?? '').isNotEmpty;
    final hasEmail = (exhibitor.email ?? '').isNotEmpty;

    return Row(
      children: [
        actionButton(
          icon: Icons.language,
          title: 'Сайт',
          onTap: hasWebsite ? () => openUrl(exhibitor.website!) : null,
        ),
        const SizedBox(width: 10),
        actionButton(
          icon: Icons.phone,
          title: 'Позвонить',
          onTap: hasPhone ? () => callPhone(exhibitor.phone) : null,
        ),
        const SizedBox(width: 10),
        actionButton(
          icon: Icons.email,
          title: 'Email',
          onTap: hasEmail ? () => sendEmail(exhibitor.email) : null,
        ),
      ],
    );
  }

  Widget infoTile({
    required IconData icon,
    required String title,
    required String? value,
  }) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.black87),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget descriptionBlock() {
    final description = exhibitor.description;

    if (description == null || description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'О компании',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 15,
              height: 1.45,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget favoriteButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onFavoriteChanged,
        icon: Icon(
          isFavorite ? Icons.star : Icons.star_border,
          color: isFavorite ? const Color(0xFFFACA2C) : Colors.black,
        ),
        label: Text(
          isFavorite ? 'В избранном' : 'Добавить в избранное',
          style: const TextStyle(color: Colors.black),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(15),
          side: const BorderSide(color: Color(0xFFFACA2C)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = [
      exhibitor.country,
      exhibitor.city,
    ].where((e) => e != null && e.isNotEmpty).join(', ');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Участник'),
        backgroundColor: const Color(0xFFFACA2C),
        actions: [
          IconButton(
            onPressed: onFavoriteChanged,
            icon: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          headerBlock(),
          const SizedBox(height: 14),
          quickActions(),
          const SizedBox(height: 14),
          favoriteButton(),
          const SizedBox(height: 16),
          descriptionBlock(),
          infoTile(
            icon: Icons.store,
            title: 'Компания',
            value: exhibitor.name,
          ),
          infoTile(
            icon: Icons.category,
            title: 'Категория',
            value: exhibitor.category,
          ),
          infoTile(
            icon: Icons.location_on,
            title: 'Стенд',
            value: exhibitor.standNumber,
          ),
          infoTile(
            icon: Icons.public,
            title: 'Локация',
            value: location.isEmpty ? null : location,
          ),
          infoTile(
            icon: Icons.phone,
            title: 'Телефон',
            value: exhibitor.phone,
          ),
          infoTile(
            icon: Icons.email,
            title: 'Email',
            value: exhibitor.email,
          ),
          infoTile(
            icon: Icons.language,
            title: 'Сайт',
            value: exhibitor.website,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}