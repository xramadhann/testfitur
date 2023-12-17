import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(MaterialApp(
    home: ChatScreen(),
  ));
}

class UserProfile {
  final String username;
  final String profilePictureUrl;

  UserProfile({required this.username, required this.profilePictureUrl});
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _questionController = TextEditingController();
  List<Map<String, String>> chatHistory = [];
  UserProfile userProfile =
      UserProfile(username: 'Pengguna', profilePictureUrl: '');

  @override
  void initState() {
    super.initState();
    fetchUserProfile().then((userProfileData) async {
      setState(() {
        userProfile = userProfileData;
      });

      await fetchDataAllHistory(); // Tunggu hingga fetchDataAllHistory selesai
      setState(() {
        _addToChatHistory(
          "Bot",
          "Hai ${userProfile.username}. Kenalin aku Helper yang akan membantu kamu. Apakah ada yang bisa aku bantu?",
        );
      });
    });
  }

  Future<void> fetchDataAllHistory() async {
    try {
      // Buat objek Dio
      Dio dio = Dio();

      // Panggil API dengan method GET
      Response response = await dio.get(
          'https://api-ferminacare.tech/api/v1/career/get-all-history-chat');

      // Lakukan sesuatu dengan data yang didapat
      if (response.statusCode == 200) {
        // Data berhasil didapat
        var data = response.data;
        // Lakukan sesuatu dengan data, contohnya tampilkan di console
        print(data);
      } else {
        // Gagal mendapatkan data, tampilkan pesan error
        print('Gagal mendapatkan data: ${response.statusCode}');
      }
    } catch (e) {
      // Tangani error jika terjadi kesalahan dalam pemanggilan
      print('Error: $e');
    }
  }

  Future<UserProfile> fetchUserProfile() async {
    String apiUrl = 'https://api-ferminacare.tech/api/v1/users/profile';
    String token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwiZnVsbF9uYW1lIjoicHV0cmlkaWFuYSIsImVtYWlsIjoicHV0cmlAZ21haWwuY29tIiwicm9sZSI6InVzZXIiLCJleHAiOjE3MDIzMzA2MDF9.7-jerT-AfBuiDo4dufWDlqC6e6Daba4xUdOrut0T2F8'; // Ganti dengan token bearer Anda

    try {
      Response response = await Dio().get(
        apiUrl,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      Map<String, dynamic> userData = response.data['data'];

      return UserProfile(
        username: userData['username'],
        profilePictureUrl: userData['profile_picture'],
      );
    } catch (e) {
      print('Error fetching user profile: $e');
      return UserProfile(username: 'Pengguna', profilePictureUrl: '');
    }
  }

  Future<void> _askGPT() async {
    String apiKey = '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';
    Dio dio = Dio(BaseOptions(
      baseUrl: 'https://api.openai.com/v1',
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
    ));

    String question = _questionController.text;
    _addToChatHistory("User", question);

    Map<String, dynamic> data = {
      "model": "gpt-3.5-turbo",
      "messages": [
        {
          "role": "system",
          "content":
              "You are a helpful assistant. dengan data berikut Tentang aplikasi Femina Care : Femina care adalah sebuah aplikasi yang bergerak untuk masalah kesehatan mental dan rekomendasi karir untuk wanita. jika anda lupa password atau lupa kata sandi silahkan Yang pertama harus kamu lakukan yaitu pergi ke halaman profil terlebih dahulu, kemudian klik pengaturan akun lalu pilih perbarui kata sandi. jika user mengatakan baik atau terimakasih atas bantuannya maka anda akan menjawab Sama-sama. Apakah ada pertanyaan lain?. jika user menjawab Tidak ada lagi Helper. maka kamu akan menjawab Baik jika tidak ada. Senang bisa membantu kamu. Bagaiaman cara membeli paket konseling? Kamu pergi ke menu order kemudia pilih paket konseling yang diinginkan, setelah itu pilih konselor dan jadwal yang tertera langkah terakhir lakukan pembayaran"
        },
        {
          "role": "user",
          "content": question,
        }
      ]
    };

    try {
      Response response = await dio
          .post('https://api.openai.com/v1/chat/completions', data: data);
      setState(() {
        String answer = response.data['choices'][0]['message']['content'];
        _addToChatHistory("Bot", answer);
      });
      print('Response: $answer');
    } catch (e) {
      print(e);
    }
  }

  void _addToChatHistory(String sender, String message) {
    setState(() {
      if (message.length > 1000) {
        message = message.substring(0, 50) + "...";
      }
      chatHistory.add({
        'sender': sender,
        'message': message,
      });
    });
  }

  Widget _buildChatBubble(String sender, String message) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment:
            sender == "Bot" ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: <Widget>[
          sender == "Bot"
              ? Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage('Assets/images/bot.png'),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          constraints: const BoxConstraints(
                            maxWidth: 200.0,
                          ),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4518D),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            message,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Container(
                      constraints: const BoxConstraints(
                        maxWidth: 200.0,
                      ),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(179, 195, 195, 195),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        message,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundImage:
                          NetworkImage(userProfile.profilePictureUrl),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Tambahkan fungsi untuk kembali ke layar sebelumnya
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('Assets/images/bot.png'),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bot Customer Service',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: chatHistory.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildChatBubble(
                  chatHistory[index]['sender']!,
                  chatHistory[index]['message']!,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _questionController,
                    decoration: InputDecoration(
                      hintText: 'Enter your question...',
                      hintStyle: TextStyle(color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.mic),
                        onPressed: () {
                          // Tambahkan logika untuk speech-to-text di sini
                        },
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF4518D),
                      ),
                    ),
                    IconButton(
                      icon: Transform.rotate(
                        angle: 315 * 3.14159265359 / 180,
                        child: Icon(Icons.send),
                      ),
                      onPressed: () {
                        if (_questionController.text.isNotEmpty) {
                          _askGPT();
                          _questionController.clear();
                        }
                      },
                      color: Colors.white,
                      iconSize: 30,
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

mixin answer {}
