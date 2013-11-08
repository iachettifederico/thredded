require 'spec_helper'

module Thredded
  describe UserTopicDecorator, 'delegated methods' do
    it 'responds to topic decorator methods' do
      topic = create(:topic, with_posts: 2)
      user = create(:user)
      decorator = UserTopicDecorator.new(user, topic)

      expect(decorator).to respond_to(:created_at_timeago)
      expect(decorator).to respond_to(:gravatar_url)
      expect(decorator).to respond_to(:last_user_link)
      expect(decorator).to respond_to(:original)
      expect(decorator).to respond_to(:updated_at_timeago)
    end
  end

  describe UserTopicDecorator, '.decorate_all' do
    it 'decorates all topics' do
      topics = [create(:topic), create(:topic)]
      user = create(:user)

      decorator = UserTopicDecorator.decorate_all(user, topics)
      expect(decorator).to have(2).items
    end
  end

  describe  UserTopicDecorator, '#read?' do
    it 'is true if the posts counts match' do
      topic = create(:topic, with_posts: 2)
      user = create(:user)
      read_status = create(:user_topic_read,
        topic: topic,
        user: user,
        posts_count: 2
      )
      decorator = UserTopicDecorator.new(user, topic)

      expect(decorator.read?).to eq true
    end

    it 'is false if the posts counts match' do
      topic = create(:topic, with_posts: 4)
      user = create(:user)
      read_status = create(:user_topic_read,
        topic: topic,
        user: user,
        posts_count: 2
      )
      decorator = UserTopicDecorator.new(user, topic)

      expect(decorator.read?).to eq false
    end

    it 'is false if we have a null user' do
      topic = create(:topic, with_posts: 2)
      user = nil
      decorator = UserTopicDecorator.new(user, topic)

      expect(decorator.read?).to eq false
    end
  end

  describe UserTopicDecorator, '#farthest_page' do
    it 'returns the farthest page a user has gotten to' do
      topic = create(:topic, with_posts: 2)
      user = create(:user)
      read_status = create(:user_topic_read,
        topic: topic,
        user: user,
        posts_count: 2,
        page: 4
      )
      decorator = UserTopicDecorator.new(user, topic)

      expect(decorator.farthest_page).to eq 4
    end

    it 'defaults to page 1 with null users' do
      topic = create(:topic, with_posts: 2)
      user = nil
      decorator = UserTopicDecorator.new(user, topic)

      expect(decorator.farthest_page).to eq 1
    end
  end

  describe UserTopicDecorator, '#farthest_post' do
    it 'returns the last post a user has read up to' do
      topic = create(:topic, with_posts: 2)
      user = create(:user)
      read_status = create(:user_topic_read,
        topic: topic,
        user: user,
        posts_count: 2,
        page: 4,
        farthest_post: topic.posts.last
      )
      decorator = UserTopicDecorator.new(user, topic)

      expect(decorator.farthest_post).to eq topic.posts.last
    end

    it 'defaults to page 1 with null users' do
      topic = create(:topic, with_posts: 2)
      user = nil
      decorator = UserTopicDecorator.new(user, topic)

      expect(decorator.farthest_post).not_to be_persisted
    end
  end

  describe UserTopicDecorator, '#css_class' do
    it 'prepends a read class to a topic' do
      topic = create(:topic, :locked, :sticky, with_posts: 2)
      user = create(:user)
      read_status = create(:user_topic_read,
        topic: topic,
        user: user,
        posts_count: 2,
        page: 4
      )
      decorator = UserTopicDecorator.new(user, topic)
      expect(decorator.css_class).to eq 'read locked sticky'
    end

    it 'prepends a unread class to a topic' do
      topic = create(:topic, :locked, :sticky, with_posts: 2)
      user = create(:user)
      read_status = create(:user_topic_read,
        topic: topic,
        user: user,
        posts_count: 1,
        page: 4
      )
      decorator = UserTopicDecorator.new(user, topic)
      expect(decorator.css_class).to eq 'unread locked sticky'
    end
  end

  describe UserTopicDecorator, '#user_link' do
    after do
      Thredded.user_path = nil
    end

    it 'links to a valid user' do
      Thredded.user_path = ->(user){ "/i_am/#{user}" }
      user = create(:user, name: 'joel')
      topic = create(:topic, user: user)
      read_status = create(:user_topic_read,
        topic: topic,
        user: user,
      )
      decorator = UserTopicDecorator.new(user, topic)

      expect(decorator.user_link).to eq "<a href='/i_am/joel'>joel</a>"
    end

    it 'links to nowhere for a null user' do
      user = nil
      topic = build_stubbed(:topic, user: nil)
      decorator = UserTopicDecorator.new(user, topic)

      expect(decorator.user_link).to eq '<a href="#">?</a>'
    end
  end
end