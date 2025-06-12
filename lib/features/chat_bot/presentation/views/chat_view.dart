import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../data/repos/chat_repo.dart';
import '../manager/chat_cubit.dart';
import 'widgets/chat_view_body.dart';

class ChatView extends StatelessWidget {
  static String id = 'ChatView';

  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(GetIt.instance<ChatRepo>()),
      child: const ChatViewBody(),
    );
  }
}
