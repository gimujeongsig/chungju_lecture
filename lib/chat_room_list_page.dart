import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'chat_page.dart';

class ChatRoomListPage extends StatefulWidget {
  const ChatRoomListPage({super.key});

  @override
  State<ChatRoomListPage> createState() => _ChatRoomListPageState();
}

class _ChatRoomListPageState extends State<ChatRoomListPage> {

  final supabase = Supabase.instance.client;
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _rooms = [];


  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    final data = await supabase
        .from('rooms')
        .select()
        .order('created_at', ascending: false);
    setState(() {
      _rooms = List<Map<String, dynamic>>.from(data);
    });
  }

  Future<void> _createRoom(String name) async {
    if(name.trim().isEmpty) return;
    await supabase.from('rooms').insert(
        {
          'name': name.trim(),
        });
    _controller.clear();
    _loadRooms();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("채팅방 목록"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                          hintText: "채팅방 이름",
                          border: OutlineInputBorder()
                      ),
                    )
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                    onPressed: () => _createRoom(_controller.text),
                    child: const Text("생성")
                )
              ],
            ),
          ),
          const Divider(),
          Expanded(
              child: _rooms.isEmpty
                  ? const Center(child: Text("채팅방이 없습니다."))
                  : ListView.builder(
                        itemCount: _rooms.length,
                itemBuilder: (context, index){
                  final room = _rooms[index];
                  return ListTile(
                    leading: const Icon(Icons.chat_bubble_outline),
                    title: Text(room['name'] ?? '이름 없음'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ChatPage(
                                  roomId : room['id'],
                                  roomName : room['name']
                              )
                          )
                      );
                    },
                  );
                },
              )
          )
        ],
      ),
    );
  }
}