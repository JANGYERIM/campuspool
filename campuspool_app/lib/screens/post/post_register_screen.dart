import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api/post_service.dart';
import '../home_with_nav.dart'; // 여기서 PostRegisterScreenStateInterface를 import함

class PostRegisterScreen extends StatefulWidget {
  const PostRegisterScreen({Key? key}) : super(key: key);

  @override
  PostRegisterScreenState createState() => PostRegisterScreenState();
}

class PostRegisterScreenState extends State<PostRegisterScreen>
    implements PostRegisterScreenStateInterface {
  final PostService _postService = PostService();

  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _fareController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _departureTimeController = TextEditingController();
  final TextEditingController _arrivalTimeController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _departureTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _arrivalTime = const TimeOfDay(hour: 9, minute: 30);

  bool _isDriver = false;
  bool _isDirty = false;

  @override
  bool get isDirty => _isDirty;

  void _markDirty() {
    if (!_isDirty) {
      setState(() {
        _isDirty = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _departureController.addListener(_markDirty);
    _destinationController.addListener(_markDirty);
    _fareController.addListener(_markDirty);
    _detailController.addListener(_markDirty);
    _dateController.addListener(_markDirty);
    _departureTimeController.addListener(_markDirty);
    _arrivalTimeController.addListener(_markDirty);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            dialogTheme: const DialogTheme(backgroundColor: Colors.white),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFEB5F5F),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
        _isDirty = true;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isDeparture) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isDeparture ? _departureTime : _arrivalTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            dialogTheme: const DialogTheme(backgroundColor: Colors.white),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFEB5F5F),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isDeparture) {
          _departureTime = picked;
          _departureTimeController.text = picked.format(context);
        } else {
          _arrivalTime = picked;
          _arrivalTimeController.text = picked.format(context);
        }
        _isDirty = true;
      });
    }
  }

  void _submit() async {
    try {
      await _postService.createPost(
        date: _selectedDate,
        departure: _departureController.text,
        destination: _destinationController.text,
        departureTime: _departureTime,
        arrivalTime: _arrivalTime,
        fare: _fareController.text,
        detail: _detailController.text,
        isDriver: _isDriver,
      );
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('성공',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,),),
          content: const Text('등록되었습니다.',
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black,),),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // 다이얼로그를 닫으면서 true 반환
              },
              child: Text(
                '확인',
                style: TextStyle(color: Color(0xFFEB5F5F)),
               ), 
            ),
          ],
        ),
      ).then((confirmed) {
        if (confirmed == true) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      })      ;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('등록 실패: $e')),
      );
    }
  }

  Widget _buildInputCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            '게시물 등록',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'NotoSansKR',
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (_isDirty) {
            final result = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('등록 취소'),
                content: const Text('등록을 취소하시겠습니까?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('확인')),
                ],
              ),
            );
            return result ?? false;
          }
          return true;
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('탑승자', style: TextStyle(fontFamily: 'NotoSansKR')),
                      selected: !_isDriver,
                      selectedColor: const Color(0xFFEB5F5F),
                      onSelected: (selected) => setState(() => _isDriver = false),
                    ),
                    const SizedBox(width: 16),
                    ChoiceChip(
                      label: const Text('운전자', style: TextStyle(fontFamily: 'NotoSansKR')),
                      selected: _isDriver,
                      selectedColor: const Color(0xFFEB5F5F),
                      onSelected: (selected) => setState(() => _isDriver = true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _buildInputCard(
                child: TextField(
                  controller: _dateController,
                  keyboardType: TextInputType.datetime,
                  decoration: const InputDecoration(
                    labelText: '일자 (yyyy-MM-dd)',
                    isDense: true,
                  ),
                  onTap: () => _selectDate(context),
                  readOnly: false,
                ),
              ),
              _buildInputCard(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _departureController,
                        decoration: const InputDecoration(
                          labelText: '출발지',
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _destinationController,
                        decoration: const InputDecoration(
                          labelText: '도착지',
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildInputCard(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _departureTimeController,
                        keyboardType: TextInputType.datetime,
                        decoration: const InputDecoration(
                          labelText: '출발시간',
                          isDense: true,
                        ),
                        onTap: () => _selectTime(context, true),
                        readOnly: false,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _arrivalTimeController,
                        keyboardType: TextInputType.datetime,
                        decoration: const InputDecoration(
                          labelText: '도착시간',
                          isDense: true,
                        ),
                        onTap: () => _selectTime(context, false),
                        readOnly: false,
                      ),
                    ),
                  ],
                ),
              ),
              _buildInputCard(
                child: TextField(
                  controller: _fareController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '요금',
                    isDense: true,
                  ),
                ),
              ),
              _buildInputCard(
                child: TextField(
                  controller: _detailController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: '상세 정보',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEB5F5F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  ),
                  onPressed: _submit,
                  child: const Text('등록', style: TextStyle(color: Colors.white, fontFamily: 'NotoSansKR')),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _departureController.dispose();
    _destinationController.dispose();
    _fareController.dispose();
    _detailController.dispose();
    _dateController.dispose();
    _departureTimeController.dispose();
    _arrivalTimeController.dispose();
    super.dispose();
  }
}
