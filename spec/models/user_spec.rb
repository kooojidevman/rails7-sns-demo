require 'rails_helper'

describe User do
  let(:name) { 'テスト太郎' }
  let(:email) { 'test@example.com' }
  let(:password) { '12345678' }
  let(:user) { User.new(name: name, email: email, password: password, password_confirmation: password) }

  describe '.first' do
    before do
      create(:user, name: name, email: email)
    end

    subject { described_class.first }

    it '作成されたUserを返すこと' do
      expect(subject.name).to eq('テスト太郎')
      expect(subject.email).to eq('test@example.com')
    end
  end

  describe 'validation' do
    describe 'name属性' do
      describe '文字数制限の検証' do
        context 'nicknameが20文字以下の場合' do
          let(:name) { 'あいうえおかきくけこさしすせそたちつてと' } # 20文字

          it 'User オブジェクトは有効である' do
            expect(user.valid?).to be(true)
          end
        end

        context 'nicknameが20文字を超える場合' do
          let(:name) { 'あいうえおかきくけこさしすせそたちつてとな' } # 21文字

          it 'User オブジェクトは無効である' do
            user.valid?

            expect(user.valid?).to be(false)
            expect(user.errors[:name]).to include('is too long (maximum is 20 characters)')
          end
        end
      end

      describe 'name存在性の検証' do
        context 'nameが空欄の場合' do
          let(:name) { '' }

          it 'User オブジェクトは無効である' do
            expect(user.valid?).to be(false)
            expect(user.errors[:name]).to include("can't be blank")
          end
        end
      end
    end
  end
end
