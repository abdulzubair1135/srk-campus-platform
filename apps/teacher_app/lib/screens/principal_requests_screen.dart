import 'package:flutter/material.dart';
import '../services/teacher_api_service.dart';

class PrincipalRequestsScreen extends StatefulWidget {
  const PrincipalRequestsScreen({super.key});

  @override
  State<PrincipalRequestsScreen> createState() => _PrincipalRequestsScreenState();
}

class _PrincipalRequestsScreenState extends State<PrincipalRequestsScreen> {
  List<dynamic> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    final list = await TeacherApiService().getPrincipalRequests();
    setState(() {
      _requests = list;
      _isLoading = false;
    });
  }

  void _respond(String id, String status, String note) async {
    await TeacherApiService().respondMeeting(id, status, note);
    setState(() {
      final req = _requests.firstWhere((r) => r['id'] == id);
      req['status'] = status;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Response "$status" sent to Principal')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Principal Requests', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _requests.length,
              itemBuilder: (ctx, idx) {
                final req = _requests[idx];
                final isPending = req['status'] == 'PENDING';
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: req['type'] == 'MEETING' ? Colors.purple.shade50 : Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                req['type'],
                                style: TextStyle(
                                  color: req['type'] == 'MEETING' ? Colors.purple.shade900 : Colors.blue.shade900,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            Text(req['time'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('From: ${req['from']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(req['reason'], style: const TextStyle(fontSize: 13, color: Colors.black87)),
                        const Divider(height: 24),

                        if (isPending)
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _respond(req['id'], 'ACCEPTED', 'Available in 15 min'),
                                  style: OutlinedButton.styleFrom(foregroundColor: Colors.green),
                                  child: const Text('Accept (15 min)'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _respond(req['id'], 'BUSY_IN_CLASS', 'Currently in Class 204'),
                                  style: OutlinedButton.styleFrom(foregroundColor: Colors.amber.shade900),
                                  child: const Text('In Class'),
                                ),
                              ),
                            ],
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                const Icon(Icons.check, size: 16, color: Colors.green),
                                const SizedBox(width: 6),
                                Text('Responded: ${req['status']}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
