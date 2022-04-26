class ChatUtils {
  static List<String> createChatRoomIdFromUserId(
      String currentUserId, String ctuerId) {
    return [currentUserId + ctuerId, ctuerId + currentUserId];
  }
}
