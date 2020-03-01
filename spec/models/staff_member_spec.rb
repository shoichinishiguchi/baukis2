require "rails_helper"

RSpec.describe StaffMember, type: :model do
  describe "#password=" do
    example "文字列を与えると、hashed_passwordは長さ60の文字列になる" do
      member= StaffMember.new
      member.password = "baukis"
      expect(member.hashed_password).to be_kind_of(String)
      expect(member.hashed_password.size).to eq(60)
    end

    example "nilを与えると、hashed_passwordはnilになる" do
      member= StaffMember.new(hashed_password: "x")
      member.password = nil
      expect(member.hashed_password).to be_nil
    end
  end
  describe "値の正規化" do
    example "email前後の空白を削除" do
      member = create(:staff_member, email: "test@example.com ")
      expect(member.email).to eq("test@example.com")
    end
    example "email前後の全角スペースを削除" do
      member = create(:staff_member, email: "　test@example.com　")
      expect(member.email).to eq("test@example.com")
    end
    example "family_name_kanaに含まれるひらがなをカタカナに変換" do
      member = create(:staff_member, family_name_kana: "てすと")
      expect(member.family_name_kana).to eq("テスト")
    end
    example "family_name_kanaに含まれる半角カナを全角カタカナに変換" do
      member = create(:staff_member, family_name_kana: "ﾃｽﾄ")
      expect(member.family_name_kana).to eq("テスト")
    end
  end
  describe "バリデーション" do
    let!(:staff_member){ create(:staff_member, email: "test@example.com") }
    let(:staff_member2){ build(:staff_member, email: "test@example.com") }

    example "@を2こ含むものは無効" do
      member = build(:staff_member, email: "test@@example.com")
      expect(member).not_to be_valid
    end
    example "漢字を含むfamily_name_kanaは無効" do
      member = build(:staff_member, family_name_kana: "カツ活")
      expect(member).not_to be_valid
    end
    example "長音符を含むfamily_name_kanaは有効" do
      member = build(:staff_member, family_name_kana: "エリー")
      expect(member).to be_valid
    end
    example "漢字、ひながな、カタカナ、アルファベットを含むfamily_nameは有効" do
      member = build(:staff_member, family_name: "太郎たろうタロウtaro")
      expect(member).to be_valid
    end
    example "漢字、ひながな、カタカナ、アルファベット以外を含むfamily_nameは無効" do
      member = build(:staff_member, family_name: "ファkjf＠w")
      expect(member).not_to be_valid
    end
    example "同じemailをもつメンバーがいたら無効" do
      expect(staff_member2).not_to be_valid
    end
  end
end
