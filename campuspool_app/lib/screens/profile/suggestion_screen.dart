// lib/screens/profile/suggestion_screen.dart
import 'package:flutter/material.dart';
import '../../services/api/suggestion_service.dart'; // SuggestionService 임포트
import 'package:shared_preferences/shared_preferences.dart';

class SuggestionScreen extends StatefulWidget {
  const SuggestionScreen({super.key});

  @override
  State<SuggestionScreen> createState() => _SuggestionScreenState();
}

class _SuggestionScreenState extends State<SuggestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isSending = false;
  final SuggestionService _suggestionService = SuggestionService();

  String _userEmail = '불러오는 중...'; // 초기값

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    print('SuggestionScreen: _loadUserEmail called');
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString('email');
    print('SuggestionScreen: Email from SharedPreferences: $storedEmail');
    if (mounted) { // 위젯이 여전히 유효한지 확인 후 setState 호출
      setState(() {
        _userEmail = storedEmail ?? '이메일 정보 없음';
      });
    }
  }

  Future<void> _submitSuggestion() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSending = true;
      });

      try {
        await _suggestionService.submitSuggestion(
          subject: _subjectController.text,
          content: _contentController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('건의사항이 성공적으로 제출되었습니다.')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('제출 중 오류 발생: $e')),
          );
        }
        print('Error submitting suggestion (UI): $e');
      } finally {
        if (mounted) {
          setState(() {
            _isSending = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('건의하기'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      // resizeToAvoidBottomInset: true, // 기본값이 true이므로 명시적으로 안 써도 괜찮습니다.
      body: SingleChildScrollView( // 전체 내용을 스크롤 가능하게 만듭니다.
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // 자식들을 가로로 꽉 채움
              children: <Widget>[
                _buildInfoRow(icon: Icons.person_outline, label: '발신자', value: _userEmail, theme: theme),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _subjectController,
                  decoration: InputDecoration(
                    labelText: '제목',
                    hintText: '건의사항의 제목을 입력해주세요.',
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: const Color(0xFFEB5F5F), width: 2.0),
                    ),
                    labelStyle: TextStyle(color: Colors.grey[700]),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '제목을 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: '내용',
                    hintText: '건의하실 내용을 자세히 적어주세요.',
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: const Color(0xFFEB5F5F), width: 2.0),
                    ),
                    alignLabelWithHint: true,
                    labelStyle: TextStyle(color: Colors.grey[700]),
                  ),
                  maxLines: 8, // 내용 입력 필드 높이
                  keyboardType: TextInputType.multiline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '내용을 입력해주세요.';
                    }
                    return null;
                  },
                ),
                // Spacer() 대신, 버튼을 Column의 마지막 요소로 두고,
                // SingleChildScrollView가 스크롤을 처리하도록 합니다.
                // 버튼 위에 충분한 공간을 주기 위해 SizedBox를 사용합니다.
                const SizedBox(height: 30.0), // 내용 필드와 버튼 사이의 간격
                Align( // 버튼을 오른쪽으로 정렬
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _isSending ? null : _submitSuggestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEB5F5F),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('발송', style: TextStyle(color: Colors.white)),
                  ),
                ),
                // 키보드가 올라왔을 때 스크롤 영역 확보를 위한 추가적인 하단 여백 (선택 사항)
                // MediaQuery.of(context).viewInsets.bottom은 현재 키보드 높이를 나타냅니다.
                // 하지만 SingleChildScrollView와 resizeToAvoidBottomInset: true 조합이면
                // 대부분 자동으로 처리됩니다.
                // SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 0 : 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String label, required String value, required TextTheme theme}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700], size: 20),
          const SizedBox(width: 12),
          Text('$label: ', style: theme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey[800])),
          Expanded(
            child: Text(
              value,
              style: theme.bodyMedium?.copyWith(color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}