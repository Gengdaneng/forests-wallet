import SwiftUI

struct ParentBootstrapView: View {
    @Environment(SampleWalletStore.self) private var store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FWSpace.s6) {
                Text("Forrest's Wallet")
                    .font(FWType.rounded(28, weight: .black))
                    .foregroundStyle(FWColor.spruce700)
                    .padding(.top, FWSpace.s8)

                Text("这台 iPhone 会成为唯一能记账的家长设备")
                    .font(FWType.rounded(FWType.title, weight: .heavy))
                    .foregroundStyle(FWColor.textStrong)
                    .fixedSize(horizontal: false, vertical: true)

                Text("运维打开一次注册窗口。注册完成后窗口关闭，之后用配对码给 Forrest 的 iPad。")
                    .font(FWType.text(FWType.body, weight: .regular))
                    .foregroundStyle(FWColor.textMuted)
                    .fixedSize(horizontal: false, vertical: true)

                FWCard(tone: .sunken) {
                    VStack(alignment: .leading, spacing: FWSpace.s3) {
                        Text("这本账只记录数字")
                            .font(FWType.rounded(FWType.head, weight: .bold))
                            .foregroundStyle(FWColor.textStrong)
                        Text("不接触银行卡，也不转移现金。确认时会写「已记录」，不会写「已转账」。")
                            .font(FWType.text(FWType.body, weight: .regular))
                            .foregroundStyle(FWColor.textMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                StatusBanner(kind: .norealmoney, size: .parent)

                FWButton(title: "注册为家长", tone: .primary, size: .parent, icon: .shieldCheck, block: true) {
                    store.bootstrapParent()
                }
                .accessibilityIdentifier("bootstrap.register")
            }
            .padding(.horizontal, FWSpace.gutterPhone)
            .padding(.bottom, FWSpace.s10)
        }
        .fwScreenBackground()
        .accessibilityIdentifier("screen.parent.bootstrap")
    }
}
