import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class EVotingDetailScreen extends StatefulWidget {
  final String electionId;

  const EVotingDetailScreen({super.key, required this.electionId});

  @override
  State<EVotingDetailScreen> createState() => _EVotingDetailScreenState();
}

class _EVotingDetailScreenState extends State<EVotingDetailScreen> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _selectedCandidateId;
  bool _isVoting = false;

  @override
  void initState() {
    super.initState();
    _loadElection();
  }

  Future<void> _loadElection() async {
    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final response = await auth.authService.dio.get(
        '/student/evoting/${widget.electionId}',
        options: auth.authService.authOptions(auth.token!),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _data = response.data['data'];
          _selectedCandidateId = _data?['voted_candidate_id']?.toString();
        });
      }
    } catch (e) {
      debugPrint("Error loading election: $e");
    }
    setState(() => _isLoading = false);
  }

  Future<void> _submitVote() async {
    if (_selectedCandidateId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih kandidat terlebih dahulu")),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Konfirmasi Pilihan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Anda yakin ingin memberikan suara untuk kandidat ini? Pilihan tidak dapat diubah.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Ya, Pilih"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isVoting = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final response = await auth.authService.dio.post(
        '/student/evoting/${widget.electionId}/vote',
        data: {'candidate_id': _selectedCandidateId},
        options: auth.authService.authOptions(auth.token!),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.data['message'] ?? 'Suara berhasil dicatat!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          _loadElection(); // Refresh
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.data['message'] ?? 'Gagal memberikan suara',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error voting: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Terjadi kesalahan"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    setState(() => _isVoting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(_data?['election']?['judul'] ?? 'E-Voting'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
          ? const Center(child: Text("Data tidak ditemukan"))
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    final election = _data!['election'];
    final candidates = _data!['candidates'] as List? ?? [];
    final hasVoted = _data!['has_voted'] == true;
    final status = election['status']?.toString() ?? 'upcoming';
    final isOngoing = status == 'ongoing';
    final isEnded = status == 'ended';

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Election Info Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.how_to_vote_rounded,
                              color: Colors.deepPurple,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  election['judul'] ?? 'Pemilihan',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  election['jenis'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${election['start_date']} - ${election['end_date']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (hasVoted) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                                color: Colors.green,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Anda sudah memberikan suara",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Kandidat",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ...candidates.map(
                  (candidate) => _buildCandidateCard(
                    candidate,
                    hasVoted,
                    isOngoing,
                    isEnded,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isOngoing && !hasVoted) _buildVoteButton(),
      ],
    );
  }

  Widget _buildCandidateCard(
    dynamic candidate,
    bool hasVoted,
    bool isOngoing,
    bool isEnded,
  ) {
    final candidateId = candidate['id']?.toString();
    final isSelected = _selectedCandidateId == candidateId;
    final isVotedFor =
        hasVoted && _data?['voted_candidate_id']?.toString() == candidateId;

    return GestureDetector(
      onTap: isOngoing && !hasVoted
          ? () => setState(() => _selectedCandidateId = candidateId)
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected || isVotedFor
              ? Colors.deepPurple.withOpacity(0.1)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected || isVotedFor
                ? Colors.deepPurple
                : Colors.black.withOpacity(0.05),
            width: isSelected || isVotedFor ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                image: candidate['foto'] != null
                    ? DecorationImage(
                        image: NetworkImage(candidate['foto']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: candidate['foto'] == null
                  ? const Icon(
                      Icons.person_rounded,
                      color: Colors.grey,
                      size: 30,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "No. ${candidate['no_urut']}",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    candidate['nama'] ?? 'Kandidat',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    candidate['kelas'] ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  if (isEnded && candidate['votes'] != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${candidate['votes']} suara",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isOngoing && !hasVoted)
              Radio<String>(
                value: candidateId ?? '',
                groupValue: _selectedCandidateId,
                onChanged: (v) => setState(() => _selectedCandidateId = v),
                activeColor: Colors.deepPurple,
              ),
            if (isVotedFor)
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoteButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isVoting ? null : _submitVote,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isVoting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    "BERIKAN SUARA",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }
}
