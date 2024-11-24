shared_examples_for 'attributable' do
  it { should have_many(:custom_attributes) }

  describe 'methods' do
    let(:associated_model) { described_class.name.underscore }
    let(:customizable_object) { create(associated_model) }
    let(:key) { Faker::Lorem.word }
    let(:value) { Faker::Lorem.sentence }

    describe '.set_custom_attribute' do
      subject { customizable_object.set_custom_attribute(key:, value:) }

      context 'when custom fields for model have been set' do
        before { create(:custom_field, name: key, associated_model:) }

        context 'with a valid key' do
          it 'adds a custom attribute to the object' do
            expect { subject }.to change { customizable_object.get_custom_attribute(key:) }.to(value)
          end
        end

        context 'with an invalid key' do
          subject { customizable_object.set_custom_attribute(key: invalid_key, value:) }

          context 'when key is not in allowed custom fields' do
            let(:invalid_key) { 'invalid_key' }
            let(:error_message) { I18n.t('activerecord.errors.messages.invalid_key') }

            it 'set the correct error message' do
              expect(subject.errors.full_messages).to include match(/#{error_message}/)
            end
          end

          context 'when key is blank' do
            let(:invalid_key) { '' }

            it 'set the correct error message' do
              expect(subject.errors.full_messages).to include match(/blank/)
            end
          end
        end
      end

      context 'when custom fields for model has not been set' do
        it 'does not add a custom attribute to the object' do
          expect { subject }.not_to change { customizable_object.custom_attributes }
        end

        let(:error_message) { I18n.t('activerecord.errors.messages.custom_fields_not_set') }

        it 'set the correct error message' do
          expect(subject.errors.full_messages).to include match(/#{error_message}/)
        end
      end
    end

    describe '.get_custom_attribute' do
      subject { customizable_object.get_custom_attribute(key:) }

      context 'when no custom attribute with given key exists' do
        it { is_expected.to be_nil }
      end

      context 'when custom attribute with given key exists' do
        it 'returns the custom attribute' do
          described_class.create_custom_field(key:)
          customizable_object.set_custom_attribute(key:, value:)

          expect(subject).to eq(value)
        end
      end
    end

    describe '.set_custom_field' do
      subject { described_class.create_custom_field(key:) }

      context 'when no custom field with given key exists' do
        it { expect { subject }.to change { CustomField.by_model(associated_model:).count }.by(1) }
      end

      context 'when a custom field with given key exists' do
        it 'raises a RecordInvalid exception' do
          described_class.create_custom_field(key:)
          expect { subject }.to raise_error ActiveRecord::RecordInvalid
        end
      end

      context 'when key is blank' do
        let(:key) { '' }

        it { is_expected.to be_nil }
      end
    end
  end
end
