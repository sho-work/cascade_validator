# frozen_string_literal: true

require 'spec_helper'
require 'active_model'
require 'uri'

RSpec.describe ActiveModel::Validations::CompositeValidator do
  let(:child_klass) do
    child_test_class = Class.new do
      attr_accessor :name, :age

      include ActiveModel::Validations
      validates :name, presence: true
      validates :age, presence: true, inclusion: { in: 18..65 }
    end

    stub_const('Child', child_test_class)
  end

  context 'when the value is not an array' do
    let(:klass) do
      test_class = Class.new do
        attr_accessor :child

        include ActiveModel::Validations

        validates :child, composite: true
      end

      stub_const('TestClass', test_class)
    end

    let(:model) do
      klass.new.tap do |instance|
        instance.child = child_klass.new
      end
    end

    it 'validates the value using valid? on the method passed to validates' do
      aggregate_failures do
        expect(model.valid?).to be false
        model.child.name = 'hoge'
        model.child.age = 18
        expect(model.valid?).to be true
        model.child.age = 11
        expect(model.valid?).to be false
      end
    end
  end

  context 'when the value is nil' do
    let(:klass) do
      test_class = Class.new do
        attr_accessor :child

        include ActiveModel::Validations

        validates :child, composite: true
      end

      stub_const('TestClass', test_class)
    end

    let(:model) do
      klass.new.tap do |instance|
        instance.child = child_klass.new
      end
    end

    before { model.child = nil }

    it 'skips evaluation because the cascade validator is not triggered' do
      expect(model.valid?).to be true
    end
  end

  context 'when the value is an array' do
    let(:klass) do
      children_test_class = Class.new do
        attr_accessor :children

        include ActiveModel::Validations

        validates :children, composite: true
      end

      stub_const('TestClass', children_test_class)
    end

    let(:model) do
      klass.new.tap do |instance|
        instance.children = Array.new(3) { child_klass.new }
      end
    end

    it 'validates each element in the array using valid? on the method passed to validates' do
      aggregate_failures do
        expect(model.valid?).to be false
        model.children.first.name = 'hoge'
        model.children.first.age = 18
        expect(model.valid?).to be false
        model.children[1].name = 'hoge'
        model.children[1].age = 18
        expect(model.valid?).to be false
        model.children[2].name = 'hoge'
        model.children[2].age = 18
        expect(model.valid?).to be true
        model.children[1].age = 11
        expect(model.valid?).to be false
      end
    end
  end
end

