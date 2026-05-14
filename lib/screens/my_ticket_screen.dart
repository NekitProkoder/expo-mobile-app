import 'dart:io';
import '../config/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:barcode_widget/barcode_widget.dart';


import '../services/api_service.dart';
import 'pdf_viewer_screen.dart';

class MyTicketScreen extends StatefulWidget {
  const MyTicketScreen({super.key});

  @override
  State<MyTicketScreen> createState() => _MyTicketScreenState();
}

class _MyTicketScreenState extends State<MyTicketScreen> {
  List tickets = [];
  bool isLoading = true;
  bool isDownloading = false;

  @override
  void initState() {
    super.initState();
    loadTickets();
  }

  Future<void> loadTickets() async {
    try {
      final data = await ApiService.getTickets();

      if (!mounted) return;

      setState(() {
        tickets = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки билетов: $e')),
      );
    }
  }

  Future<void> openPdfInsideApp(Map ticket) async {
    final token = await ApiService.getToken();

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не найден токен авторизации')),
      );
      return;
    }

    final ticketId = ticket['id'];
   final url =
    '${ApiConfig.baseUrl}/api/tickets/$ticketId/pdf?token=$token';

    try {
      setState(() {
        isDownloading = true;
      });

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception(response.body);
      }

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/ticket_$ticketId.pdf');

      await file.writeAsBytes(response.bodyBytes, flush: true);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfViewerScreen(
            filePath: file.path,
            title: 'Билет №$ticketId',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка открытия PDF: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isDownloading = false;
        });
      }
    }
  }

  String getStatusText(String? status) {
    switch (status) {
      case 'ticket_ready':
        return 'Билет готов';
      case 'waiting_bitrix_deal':
        return 'Ожидается создание сделки';
      case 'waiting_ticket_pdf':
        return 'Ожидается PDF билет';
      case 'created':
        return 'Заявка создана';
      default:
        return status ?? 'Неизвестный статус';
    }
  }

  Color getStatusColor(String? status) {
    switch (status) {
      case 'ticket_ready':
        return Colors.green;
      case 'waiting_bitrix_deal':
      case 'waiting_ticket_pdf':
        return Colors.orange;
      default:
        return Colors.black54;
    }
  }

  Widget ticketHeader(Map ticket) {
    final status = ticket['status'];

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Euro Shoes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Premiere Collection',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(
                Icons.verified,
                color: getStatusColor(status),
              ),
              const SizedBox(width: 8),
              Text(
                getStatusText(status),
                style: TextStyle(
                  color: getStatusColor(status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget infoRow(String title, String? value) {
    if (value == null || value.isEmpty) {
      value = '-';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

Widget barcodeBlock(String? barcode) {
  if (barcode == null || barcode.isEmpty) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: Text(
          'Штрихкод пока не готов',
          style: TextStyle(color: Colors.black54),
        ),
      ),
    );
  }

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: Colors.black12),
    ),
    child: Column(
      children: [
        const Text(
          'ПРИГЛАСИТЕЛЬНЫЙ БИЛЕТ',
          style: TextStyle(
            fontSize: 13,
            letterSpacing: 1.2,
            color: Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 18),

        BarcodeWidget(
          barcode: Barcode.code128(),
          data: barcode,
          width: 300,
          height: 90,
          drawText: false,
        ),

        const SizedBox(height: 18),

        Text(
          barcode,
          style: const TextStyle(
            fontSize: 24,
            letterSpacing: 3,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Покажите штрихкод на входе',
          style: TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
      ],
    ),
  );
}

  Widget ticketCard(Map ticket) {
    final String? status = ticket['status'];
    final String? barcode = ticket['barcode'];
    final bool isReady = status == 'ticket_ready';

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          ticketHeader(ticket),

          const SizedBox(height: 20),

          barcodeBlock(barcode),

          const SizedBox(height: 20),

          infoRow('ФИО', ticket['full_name']),
          infoRow('Email', ticket['email']),
          infoRow('Телефон', ticket['phone']),
          infoRow('Компания', ticket['company']),
          infoRow('Должность', ticket['position']),
          

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isReady && !isDownloading
                  ? () => openPdfInsideApp(ticket)
                  : null,
              icon: isDownloading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Icon(Icons.picture_as_pdf, color: Colors.black),
              label: Text(
                isDownloading ? 'Открываем билет...' : 'Открыть PDF билет',
                style: const TextStyle(color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFACA2C),
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: loadTickets,
              icon: const Icon(Icons.refresh),
              label: const Text('Обновить статус'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget emptyState() {
    return ListView(
      children: [
        const SizedBox(height: 180),
        Icon(
          Icons.confirmation_number_outlined,
          size: 82,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 18),
        const Center(
          child: Text(
            'У вас пока нет билетов',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Оформите пригласительный билет на главной странице',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFACA2C),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Мой билет'),
        backgroundColor: const Color(0xFFFACA2C),
      ),
      body: RefreshIndicator(
        onRefresh: loadTickets,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: tickets.isEmpty
              ? emptyState()
              : ListView(
                  children: tickets.map((t) => ticketCard(t)).toList(),
                ),
        ),
      ),
    );
  }
}