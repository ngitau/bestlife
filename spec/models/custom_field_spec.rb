describe CustomField do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:associated_model) }

  context 'when name is provided' do
    subject { build(:custom_field) }

    it { should validate_uniqueness_of(:name).scoped_to(:associated_model).ignoring_case_sensitivity }
  end
end
