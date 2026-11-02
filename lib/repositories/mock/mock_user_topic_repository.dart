import '../../models/user_topic.dart';
import '../user_topic_repository.dart';
import 'in_memory_repository.dart';

class MockUserTopicRepository extends InMemoryRepository<UserTopic>
    implements UserTopicRepository {
  MockUserTopicRepository({List<UserTopic> initialTopics = const []})
      : super(idOf: (topic) => topic.id, initialItems: initialTopics);
}
