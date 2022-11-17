require 'spec_helper'

module ActiveRecord
  module VERSION
    MAJOR = 3
  end
end

describe ORMProxy do

  describe ".build" do
    let(:model) { 'model' }
    let(:attributes) { {} }

    context "when active_record version equal 4" do
       before do
        ActiveRecord::VERSION.send(:remove_const, 'MAJOR')
        ActiveRecord::VERSION.const_set('MAJOR', 4)
      end

      it "initializes ORMProxy::ActiveRecord" do
        expect(ORMProxy::ActiveRecord).to receive(:new).with(model, attributes)

        ORMProxy.build(model, attributes)
      end
    end

    context "when active_record version equal 5" do
       before do
        ActiveRecord::VERSION.send(:remove_const, 'MAJOR')
        ActiveRecord::VERSION.const_set('MAJOR', 5)
      end

      it "initializes ORMProxy::ActiveRecord" do
        expect(ORMProxy::ActiveRecord).to receive(:new).with(model, attributes)

        ORMProxy.build(model, attributes)
      end
    end

    context "when active_record version equal 6" do
       before do
        ActiveRecord::VERSION.send(:remove_const, 'MAJOR')
        ActiveRecord::VERSION.const_set('MAJOR', 6)
      end

      it "initializes ORMProxy::ActiveRecord" do
        expect(ORMProxy::ActiveRecord).to receive(:new).with(model, attributes)

        ORMProxy.build(model, attributes)
      end
    end

    context "when active_record version less than 4" do
      before do
        ActiveRecord::VERSION.send(:remove_const, 'MAJOR')
        ActiveRecord::VERSION.const_set('MAJOR', 3)
      end

      it "initializes ORMProxy::ActiveRecord" do
        expect(ORMProxy::ActiveRecord).to receive(:new).with(model, attributes)

        ORMProxy.build(model, attributes)
      end
    end
  end

  describe ".initialize" do
    let(:model_name) { 'shops' }
    let(:attributes) { {'id' => 1, 'name' => 'name', 'title' => 'title' } }

    subject { described_class.new(model_name, attributes) }

    context "when model responds to 'column_names'" do
      class Shop
        def self.column_names
          ['id', 'name', 'updated_at']
        end
      end

      it "sets only attributes which has model" do
        expect(subject.attributes).to eq({'id' => 1, 'name' => 'name'})
      end
    end

    context "when model doesn't respond to 'column_names'" do
      let(:model_name) { 'cars' }
      class Car;end

      it "sets all passed attributes" do
        expect(subject.attributes).to eq(attributes)
      end
    end

    context "when passed habtms associations" do
      let(:model_name) { 'gateways' }
      class Gateway;end

      let(:attributes) { {'id' => 1, '_adds' => {'habtms' => {'brands' => ['1', '2', '3']}}} }
      it "sets habtms values" do
        expect(subject.habtms).to eq({'brands' => ['1', '2', '3']})
      end
    end
  end

end
