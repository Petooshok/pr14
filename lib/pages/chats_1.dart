import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/pages/chat_page.dart';
import '/services_2/auth/auth_service_2.dart';
import 'package:provider/provider.dart';

class Chats extends StatefulWidget {
  const Chats({super.key});

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  // Instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign out user
  void signOut() {
    // Get auth service
    final authService = Provider.of<AuthService>(context, listen: false);

    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'MANgo100',
            style: TextStyle(fontSize: 24, color: Color(0xFFECDBBA)), // Цвет текста
          ),
        ),
        backgroundColor: const Color(0xFF2D4263), // Цвет AppBar
        actions: [
          IconButton(
            onPressed: signOut,
            icon: const Icon(
              Icons.logout,
              color: Color(0xFFECDBBA), // Цвет иконки
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF191919), // Цвет фона
      body: _buildUserList(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Build a list of users
  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
            'Error',
            style: TextStyle(color: Color(0xFFECDBBA)), // Цвет текста
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFECDBBA), // Цвет индикатора загрузки
            ),
          );
        }

        // Фильтруем пользователей
        final users = snapshot.data!.docs;

        // Если текущий пользователь не "mari.vas.04@mail.ru", показываем только этого пользователя
        if (_auth.currentUser!.email != 'mari.vas.04@mail.ru') {
          return ListView(
            children: users
                .where((x) => x['email'] == 'mari.vas.04@mail.ru')
                .map<Widget>((doc) => _buildUserListItem(doc))
                .toList(),
          );
        } else {
          // Иначе показываем всех пользователей, кроме текущего
          return ListView(
            children: users
                .where((doc) => doc['email'] != _auth.currentUser!.email)
                .map<Widget>((doc) => _buildUserListItem(doc))
                .toList(),
          );
        }
      },
    );
  }

  // Build individual user list items
  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    // Display all users except current user
    if (_auth.currentUser!.email != data['email']) {
      return ListTile(
        title: Text(
          data['email'],
          style: const TextStyle(color: Color(0xFFECDBBA)), // Цвет текста
        ),
        onTap: () {
          // Pass the user's UID
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverUserEmail: data['email'],
                receiverUserId: data['uid'],
              ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Главная',
          backgroundColor: Color(0xFF2D4263), // Цвет фона
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Избранное',
          backgroundColor: Color(0xFF2D4263), // Цвет фона
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Корзина',
          backgroundColor: Color(0xFF2D4263), // Цвет фона
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Профиль',
          backgroundColor: Color(0xFF2D4263), // Цвет фона
        ),
      ],
      currentIndex: 3, // Устанавливаем текущий индекс на "Профиль"
      selectedItemColor: const Color(0xFFC84B31), // Цвет активного элемента
      unselectedItemColor: const Color(0xFFECDBBA), // Цвет неактивных элементов
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (index == 1) {
          Navigator.pushReplacementNamed(context, '/manga_selected');
        } else if (index == 2) {
          Navigator.pushReplacementNamed(context, '/cart');
        } else if (index == 3) {
          Navigator.pushReplacementNamed(context, '/profile');
        }
      },
    );
  }
}