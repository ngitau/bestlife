describe CustomAttribute do
  it { should belong_to(:attributable) }

  it { should validate_presence_of(:key) }
  it { should validate_presence_of(:value) }

  context 'when key is provided' do
    subject { create(:custom_attribute_for_customer) }

    it { should validate_uniqueness_of(:key).scoped_to(:attributable_type, :attributable_id).ignoring_case_sensitivity }
  end
end
