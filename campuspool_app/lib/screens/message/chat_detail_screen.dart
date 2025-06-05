import 'package:campuspool_app/utils/user_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // for debugPrint

import '../../models/message.dart';
import '../../services/api/chat_service.dart';
import '../../services/api/reservation_service.dart';
import '../../models/reservation.dart';
import '../../models/reservation_status.dart';

class ChatDetailScreen extends StatefulWidget {
  final String roomId;
  final String profileImage;
  final String nickname;
  final String opponentUsername;
  final Map<String, dynamic> postData;
  final VoidCallback onBack;

  const ChatDetailScreen({
    Key? key,
    required this.roomId,
    required this.profileImage,
    required this.nickname,
    required this.opponentUsername,
    required this.postData,
    required this.onBack,
  }) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  Future<List<MessageModel>>? _messagesFuture;
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  String? currentUser;
  bool _isCurrentUserPostAuthor = false;
  String? _currentRelevantPostId;

  final ReservationService _reservationService = ReservationService();
  Reservation? _reservation;
  ReservationStatus _currentButtonStatus = ReservationStatus.NONE;
  bool _isReservationLoading = false;

  @override
  void initState() {
    super.initState();

    dynamic postIdValueFromData;
    if (widget.postData.containsKey('id')) {
      postIdValueFromData = widget.postData['id'];
    } else if (widget.postData.containsKey('postId')) {
      postIdValueFromData = widget.postData['postId'];
    }

    if (postIdValueFromData != null) {
      _currentRelevantPostId = postIdValueFromData.toString();
      if (postIdValueFromData is! String && postIdValueFromData is! int) {
        debugPrint("[ChatDetailScreen] Warning: postId was of type ${postIdValueFromData.runtimeType}, converted to String: $_currentRelevantPostId");
      }
    } else {
      debugPrint("[ChatDetailScreen] Info: No 'id' or 'postId' key found in postData for reservation features.");
    }

    debugPrint("[ChatDetailScreen] initState: roomId=${widget.roomId}, relevantPostId=$_currentRelevantPostId");
    _initChatAndReservation();
  }

  Future<void> _initChatAndReservation() async {
    currentUser = await getLoginUserId();
    if (!mounted) return;

    if (currentUser == null) {
      debugPrint('[ChatDetailScreen] User not logged in.');
      widget.onBack();
      return;
    }
    debugPrint('[ChatDetailScreen] Current user ID loaded: $currentUser');

    _checkIfCurrentUserIsAuthor();

    if (mounted) {
      setState(() {
        _messagesFuture = _chatService.fetchMessages(widget.roomId, currentUser!);
      });
    }

    final postIdForReservation = int.tryParse(_currentRelevantPostId ?? '');
    if (postIdForReservation != null) {
      await _fetchInitialReservationStatus(postIdForReservation);
    } else {
      debugPrint("[ChatDetailScreen] Error: Could not parse postId '$_currentRelevantPostId' for reservation status fetch.");
    }

    _chatService.connectToRoom(
      roomId: widget.roomId,
      currentUser: currentUser!,
      onMessageReceived: (data) {
        if (mounted) {
          debugPrint("[ChatDetailScreen] New message received, refreshing messages...");
          setState(() {
            _messagesFuture = _chatService.fetchMessages(widget.roomId, currentUser!);
          });
        }
      },
    );
  }

  void _checkIfCurrentUserIsAuthor() {
    debugPrint("[ChatDetailScreen] _checkIfCurrentUserIsAuthor called. Full widget.postData: ${widget.postData}");
    if (widget.postData.isNotEmpty && currentUser != null) {
      final String? postAuthorId = widget.postData['userId']?.toString(); // ✅ Postman 응답 기준 (user 객체 안의 userId)
      debugPrint("[ChatDetailScreen] Checking author. currentUser: $currentUser, postData Author ID from Key ('user' -> 'userId'): $postAuthorId");

      bool determinedIsAuthor = false;
      if (postAuthorId != null && postAuthorId == currentUser) {
        determinedIsAuthor = true;
      }

      if (mounted && _isCurrentUserPostAuthor != determinedIsAuthor) {
        setState(() {
          _isCurrentUserPostAuthor = determinedIsAuthor;
        });
      }
      debugPrint("[ChatDetailScreen] _isCurrentUserPostAuthor set to: $_isCurrentUserPostAuthor");
    } else {
      debugPrint("[ChatDetailScreen] Cannot check author: currentUser is null or postData is empty.");
      if (mounted && _isCurrentUserPostAuthor) {
        setState(() => _isCurrentUserPostAuthor = false);
      }
    }
  }

  Future<void> _fetchInitialReservationStatus(int postId) async {
    if (!mounted) return;
    setState(() => _isReservationLoading = true);

    try {
      final reservationData = await _reservationService.fetchReservationStatus(postId);
      if (!mounted) return;

      if (reservationData != null) {
        setState(() {
          _reservation = reservationData;
          _currentButtonStatus = reservationData.status;
        });
        debugPrint("[ChatDetailScreen] Fetched reservation status: ${_currentButtonStatus.name}, Reservation ID: ${_reservation?.id}");
      } else {
        setState(() {
          _reservation = null;
          _currentButtonStatus = ReservationStatus.NONE;
        });
        debugPrint("[ChatDetailScreen] No reservation found for postId $postId, status set to NONE.");
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint("[ChatDetailScreen] Error fetching reservation status: $e");
      if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('예약 상태 조회 오류: $e')));
      setState(() {
        _reservation = null;
        _currentButtonStatus = ReservationStatus.NONE;
      });
    } finally {
      if (!mounted) return;
      setState(() => _isReservationLoading = false);
    }
  }

  Future<void> _handleRequestReservation() async {
    if (_currentRelevantPostId == null) {
       if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('게시물 ID가 없어 예약 요청을 할 수 없습니다.')));
      return;
    }
    final postId = int.tryParse(_currentRelevantPostId!);
    if (postId == null) {
       if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('유효하지 않은 게시물 ID입니다.')));
      return;
    }

    if (!mounted) return;
    setState(() => _isReservationLoading = true);

    try {
      final newReservation = await _reservationService.requestReservation(postId);
      if (!mounted) return;
       if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('예약 요청이 전송되었습니다.')));
      setState(() {
        _reservation = newReservation;
        _currentButtonStatus = newReservation.status;
      });
    } catch (e) {
      if (!mounted) return;
      debugPrint("[ChatDetailScreen] Error requesting reservation: $e");
       if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('예약 요청 실패: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _isReservationLoading = false);
    }
  }

  Future<void> _handleAcceptReservation() async {
    if (_reservation == null || _reservation?.id == null) {
       if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('수락할 예약 정보가 없습니다.')));
      return;
    }
    if (!mounted) return;
    setState(() => _isReservationLoading = true);

    try {
      final updatedReservation = await _reservationService.acceptReservation(_reservation!.id);
      if (!mounted) return;
       if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('예약이 수락되었습니다.')));
      setState(() {
        _reservation = updatedReservation;
        _currentButtonStatus = updatedReservation.status;
      });
    } catch (e) {
      if (!mounted) return;
      debugPrint("[ChatDetailScreen] Error accepting reservation: $e");
       if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('예약 수락 실패: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _isReservationLoading = false);
    }
  }

  @override
  void dispose() {
    debugPrint("[ChatDetailScreen] dispose called. Disconnecting chat service.");
    _chatService.disconnect();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || currentUser == null) return;
    debugPrint("[ChatDetailScreen] Sending message with postId: $_currentRelevantPostId, text: $text");
    _chatService.sendMessage(
      sender: currentUser!,
      receiver: widget.opponentUsername,
      message: text,
      postId: _currentRelevantPostId,
    );
    _messageController.clear();
  }

  Widget _buildMessage(MessageModel msg) {
    final isMine = msg.isMe;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isMine ? const Color(0xFFEB5F5F) : const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: Radius.circular(isMine ? 15 : 3),
            bottomRight: Radius.circular(isMine ? 3 : 15),
          ),
          boxShadow: [ BoxShadow( color: Colors.grey.withOpacity(0.3), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 1),)],
        ),
        child: Text( msg.content, style: TextStyle( color: isMine ? Colors.white : Colors.black87, fontSize: 14, height: 1.5, ),),
      ),
    );
  }

  Widget _buildTripInfo() {
    if (widget.postData.isEmpty) {
      debugPrint("[ChatDetailScreen] _buildTripInfo: postData is empty. Not showing trip info.");
      return const SizedBox.shrink();
    }
    debugPrint("[ChatDetailScreen] _buildTripInfo: Building trip info. _isCurrentUserPostAuthor: $_isCurrentUserPostAuthor, _currentButtonStatus: ${_currentButtonStatus.name}, Reservation ID: ${_reservation?.id}");

    final String date = widget.postData['date'] as String? ?? '날짜 정보 없음';
    final String departureTime = widget.postData['departureTime'] as String? ?? '시간 정보 없음';
    final String arrivalTime = widget.postData['arrivalTime'] as String? ?? '';
    final String departure = widget.postData['departure'] as String? ?? '출발지 정보 없음';
    final String destination = widget.postData['destination'] as String? ?? '도착지 정보 없음';
    final dynamic fareValue = widget.postData['fare'];
    final String fare = (fareValue != null && fareValue.toString().isNotEmpty)
        ? '${fareValue.toString()}원'
        : '요금 정보 없음';

    Widget reservationButtonWidget;
    if (_isReservationLoading) {
      reservationButtonWidget = const SizedBox(
        height: 24, width: 24,
        child: CircularProgressIndicator(strokeWidth: 2.0, color: Color(0xFFEB5F5F)),
      );
    } else {
      if (_isCurrentUserPostAuthor) {
        switch (_currentButtonStatus) {
          case ReservationStatus.REQUESTED:
            reservationButtonWidget = ElevatedButton(
              onPressed: _handleAcceptReservation,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEB5F5F), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              child: const Text('요청 수락하기'),
            );
            break;
          case ReservationStatus.ACCEPTED:
            reservationButtonWidget = ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEB5F5F), // 비활성화시에도 기본 배경색 유지 (원래 의도)
                disabledBackgroundColor: const Color(0xFFEB5F5F), // ✅ 비활성화 시 배경색을 핑크로!
                disabledForegroundColor: Colors.white.withOpacity(0.85),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('예약 확정됨'),
            );
            break;
          case ReservationStatus.CANCELLED:
          case ReservationStatus.REJECTED:
             reservationButtonWidget = ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, disabledForegroundColor: Colors.white.withOpacity(0.8), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              child: Text(_currentButtonStatus == ReservationStatus.CANCELLED ? '예약 취소됨' : '요청 거절됨'),
            );
            break;
          case ReservationStatus.NONE:
          default:
            reservationButtonWidget = const Text('예약 요청 없음', style: TextStyle(color: Colors.grey));
            break;
        }
      } else {
        switch (_currentButtonStatus) {
          case ReservationStatus.REQUESTED:
            reservationButtonWidget = ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[600], disabledForegroundColor: Colors.white.withOpacity(0.8), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              child: const Text('수락 대기중'),
            );
            break;
          case ReservationStatus.ACCEPTED:
            reservationButtonWidget = ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEB5F5F), // 비활성화시에도 기본 배경색 유지
                disabledBackgroundColor: const Color(0xFFEB5F5F), // ✅ 비활성화 시 배경색을 핑크로!
                disabledForegroundColor: Colors.white.withOpacity(0.85),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              child: const Text('예약 확정됨'),
            );
            break;
          case ReservationStatus.CANCELLED:
          case ReservationStatus.REJECTED:
             reservationButtonWidget = ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, disabledForegroundColor: Colors.white.withOpacity(0.8),padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              child: Text(_currentButtonStatus == ReservationStatus.CANCELLED ? '예약 취소됨' : '요청 거절됨'),
            );
            break;
          case ReservationStatus.NONE:
          default:
            reservationButtonWidget = ElevatedButton(
              onPressed: _handleRequestReservation,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEB5F5F), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              child: const Text('예약 요청'),
            );
            break;
        }
      }
    }

    return Container(
      padding: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [const Icon(Icons.calendar_today, size: 14, color: Colors.grey), const SizedBox(width: 6), Text('탑승 일시: $date', style: tripTextStyle)]),
            const SizedBox(height: 5),
            Row(children: [const Icon(Icons.access_time, size: 14, color: Colors.grey), const SizedBox(width: 6), Text('출발: $departureTime ${arrivalTime.isNotEmpty ? " / 도착: $arrivalTime" : ""}', style: tripTextStyle)]),
            const SizedBox(height: 5),
            Row(children: [const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey), const SizedBox(width: 6), Text('출발지: $departure', style: tripTextStyle)]),
            const SizedBox(height: 5),
            Row(children: [const Icon(Icons.flag_outlined, size: 14, color: Colors.grey), const SizedBox(width: 6), Text('도착지: $destination', style: tripTextStyle)]),
            const SizedBox(height: 5),
            Row(children: [const Icon(Icons.payment, size: 14, color: Colors.grey), const SizedBox(width: 6), Text('요금: $fare', style: tripTextStyle)]),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: reservationButtonWidget,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("[ChatDetailScreen] Build method. _isCurrentUserPostAuthor: $_isCurrentUserPostAuthor, _currentButtonStatus: ${_currentButtonStatus.name}");
    return WillPopScope(
      onWillPop: () async {
        widget.onBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
           backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: widget.onBack,
          ),
          title: Text(widget.nickname,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              )),
        ),
        body: Column(
          children: [
            if (widget.postData.isNotEmpty) _buildTripInfo(),
            Expanded(
              child: FutureBuilder<List<MessageModel>>(
                future: _messagesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && _messagesFuture != null) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('오류 발생: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('메시지가 없습니다. 대화를 시작해보세요!'));
                  }
                  final msgs = snapshot.data!;
                  return ListView.builder(
                     padding: const EdgeInsets.all(8.0),
                    itemCount: msgs.length,
                    itemBuilder: (context, index) {
                      final msg = msgs[index];
                      bool showDate = false;
                      if (index == 0) {
                        showDate = true;
                      } else {
                        final prevMsg = msgs[index - 1];
                        if (prevMsg.timestamp.year != msg.timestamp.year ||
                            prevMsg.timestamp.month != msg.timestamp.month ||
                            prevMsg.timestamp.day != msg.timestamp.day) {
                          showDate = true;
                        }
                      }
                      return Column(
                        children: [
                          if (showDate)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: Text(
                                _formatDate(msg.timestamp),
                                style: TextStyle( color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.normal,),
                              ),
                            ),
                          _buildMessage(msg),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            _buildInputBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBox() {
     return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border( top: BorderSide(color: Colors.grey[300]!, width: 0.5),),
        boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.05), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, -3),)]
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: '메시지를 입력하세요...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                enabledBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Colors.grey[200]!),),
                focusedBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),),
              ),
              textCapitalization: TextCapitalization.sentences,
              minLines: 1,
              maxLines: 5,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: _sendMessage,
            borderRadius: BorderRadius.circular(25),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration( color: Color(0xFFEB5F5F), shape: BoxShape.circle,),
              child: const Icon(Icons.send, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return "오늘";
    } else if (dt.year == now.year && dt.month == now.month && dt.day == now.day -1) {
      return "어제";
    }
    return '${dt.year}년 ${dt.month}월 ${dt.day}일';
  }
}

const tripTextStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.normal,
  color: Colors.black87,
);

class ReservationButton extends StatelessWidget {
  final VoidCallback onPressed; // ✅ onPressed 콜백을 받도록 수정

  const ReservationButton({
    Key? key,
    required this.onPressed, // ✅ 생성자에서 onPressed를 받도록 수정
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed, // ✅ 전달받은 onPressed 콜백 사용
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEB5F5F),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 2,
      ),
      child: const Text(
        '예약 요청',
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}