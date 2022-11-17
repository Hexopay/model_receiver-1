require 'spec_helper'

describe ORMProxy::ActiveRecord do

  describe "#update_db" do
    let(:model)  { 'shops' }
    let(:updated_at) { Time.now.to_s }
    let(:attributes) { {'id' => 1, 'name' => 'test', 'updated_at' => updated_at} }
    let(:attrs_for_update) { {'name' => 'test', 'updated_at' => updated_at} }

    let(:proxy) { described_class.new(model, attributes) }

    context "when model class exists" do
      class Shop; end

      context "when record doesn't exist" do
        it "adds new record" do
          expect(Shop).to receive(:find_by_id).with(1).and_return(nil)
          expect(Shop).to receive(:create!).with(attributes)

          proxy.update_db
        end
      end

      context "when record already exists" do
        let(:record) { double('record') }

        it "updates record" do
          expect(Shop).to receive(:find_by_id).with(1).and_return(record)
          expect(record).to receive(:with_lock).and_yield
          expect(record).to receive(:respond_to?).and_return(true)
          expect(record).to receive(:updated_at).and_return(Time.now - 5*60)
          expect(record).to receive(:update).with(attrs_for_update)

          proxy.update_db
        end

        context "and there outedated update" do
          let(:updated_at) { (Time.now - 10).to_s }

          it "skips outdated record update" do
            expect(Shop).to receive(:find_by_id).with(1).and_return(record)
            expect(record).to receive(:with_lock).and_yield
            expect(record).to receive(:respond_to?).and_return(true)
            expect(record).to receive(:updated_at).and_return(Time.now)
            expect(record).not_to receive(:update)

            proxy.update_db
          end
        end
      end

      context "when habtms is present" do
        class BrandsShop; end
        class Relation;
          def self.delete_all; end
        end

        let(:record) { double('record', id: 1) }
        let(:attributes) { {'id' => 1, 'name' => 'test', 'updated_at' => updated_at, '_adds' => {'habtms' => {'brands' => ['1', '2']}}} }

        before do
          expect(Shop).to receive(:find_by_id).with(1).and_return(record)
          expect(record).to receive(:with_lock).and_yield
          expect(record).to receive(:update).with(attrs_for_update)
        end

        it "deletes all habmts previous values and inserts new passed values" do
          expect(BrandsShop).to receive(:where).with(["shop_id = ?", 1]).and_return(Relation)
          expect(BrandsShop).to receive(:create!).with({'shop_id' => 1, 'brand_id' => '1'})
          expect(BrandsShop).to receive(:create!).with({'shop_id' => 1, 'brand_id' => '2'})

          proxy.update_db
        end
      end

      context "when _model_name attribute present" do
        class NewModel; end

        let(:attributes) { { 'id' => 1, 'name' => 'test', 'updated_at' => updated_at, '_model_name' => 'NewModel' } }

        it "uses passed model name as model class" do
          expect(NewModel).to receive(:find_by_id).with(1).and_return(nil)
          expect(NewModel).to receive(:create!).with(attributes)

          proxy.update_db
        end
      end

    end
  end

  describe "#destroy" do
    let(:model)  { 'shops' }
    let(:attributes) { {'id' => 1, 'name' => 'test'} }
    let(:attrs_for_update) { {'name' => 'test'} }
    let(:record) { double('record') }
    let(:records) { [record] }

    let(:proxy) { described_class.new(model, attributes) }

    context "when model class exists" do
      class Shop; end

      context "when primary key is present" do
        it "destroys by primary key" do
          expect(Shop).to receive(:primary_key).and_return('id')
          expect(Shop).to receive(:where).with('id' => 1).and_return(records)
          expect(record).to receive(:destroy!)

          proxy.destroy
        end
      end

      context "when primary key isn't present" do
        it "destroys by attributes" do
          expect(Shop).to receive(:primary_key).and_return(nil)
          expect(Shop).to receive(:where).with(attributes).and_return(records)
          expect(record).to receive(:destroy!)

          proxy.destroy
        end
      end
    end

  end

end
