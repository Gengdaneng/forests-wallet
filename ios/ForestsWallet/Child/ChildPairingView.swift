import SwiftUI

struct ChildPairingView: View {
    @Environment(SampleWalletStore.self) private var store
    @State private var code = ""
    @State private var failed = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FWSpace.s6) {
                Text("Forrest's Wallet")
                    .font(FWType.rounded(28, weight: .black))
                    .foregroundStyle(FWColor.spruce700)
                    .padding(.top, FWSpace.s8)

                Text("请输入爸爸给你的 6 位数字")
                    .font(FWType.rounded(FWType.childTitle, weight: .heavy))
                    .foregroundStyle(FWColor.textStrong)
                    .fixedSize(horizontal: false, vertical: true)

                Text("输对了，你就能看现在有多少钱。这个 App 不会动银行卡或现金。")
                    .font(FWType.text(FWType.childBody, weight: .regular))
                    .foregroundStyle(FWColor.textMuted)
                    .fixedSize(horizontal: false, vertical: true)

                DigitHero(value: code, accessibilityName: "配对码")

                NumberPad(value: $code, maxDigits: 6)

                if failed {
                    StatusBanner(
                        kind: store.lastAuthErrorIsOffline ? .offline : .failed,
                        text: store.lastAuthErrorMessage ?? "数字不对，再问爸爸一次",
                        size: .child
                    )
                }

                FWButton(
                    title: "开始看",
                    tone: .primary,
                    size: .child,
                    block: true,
                    disabled: code.count < 6 || store.isAuthBusy
                ) {
                    Task {
                        let ok = await store.pairChild(code: code)
                        failed = !ok
                    }
                }
                .accessibilityIdentifier("child.pair.submit")
            }
            .padding(.horizontal, FWSpace.gutterPad)
            .padding(.bottom, FWSpace.s10)
            .frame(maxWidth: FWSpace.maxChildColumn)
            .frame(maxWidth: .infinity)
        }
        .fwScreenBackground()
        .accessibilityIdentifier("screen.child.pairing")
    }
}

struct ChildWelcomeView: View {
    @Environment(SampleWalletStore.self) private var store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FWSpace.s7) {
                Text("Forrest's Wallet")
                    .font(FWType.rounded(22, weight: .black))
                    .foregroundStyle(FWColor.spruce700)

                Text("这是你的账本")
                    .font(FWType.rounded(FWType.childTitle, weight: .heavy))
                    .foregroundStyle(FWColor.textStrong)

                welcomeLine(icon: .wallet, text: "你能看现在有多少钱。")
                welcomeLine(icon: .list, text: "每笔钱为什么变了，都可以自己数一遍。")
                welcomeLine(icon: .scrollText, text: "规则和目标也写在这里。")
                welcomeLine(icon: .pencil, text: "爸爸负责记录。你这边只能看，不能改。")

                StatusBanner(kind: .norealmoney, text: "App 不会动银行卡或现金", size: .child)

                FWButton(title: "开始看", tone: .accent, size: .child, block: true) {
                    store.acknowledgeChildWelcome()
                }
                .accessibilityIdentifier("child.welcome.done")
            }
            .padding(.horizontal, FWSpace.gutterPad)
            .padding(.vertical, FWSpace.s8)
            .frame(maxWidth: FWSpace.maxChildColumn)
            .frame(maxWidth: .infinity)
        }
        .fwScreenBackground()
        .accessibilityIdentifier("screen.child.welcome")
    }

    private func welcomeLine(icon: FWGlyph, text: String) -> some View {
        HStack(alignment: .top, spacing: FWSpace.s4) {
            ZStack {
                RoundedRectangle(cornerRadius: FWRadius.md, style: .continuous)
                    .fill(FWColor.surfaceLeaf)
                FWIcon(glyph: icon, size: 24)
                    .foregroundStyle(FWColor.spruce700)
            }
            .frame(width: 48, height: 48)
            Text(text)
                .font(FWType.text(FWType.childBody, weight: .regular))
                .foregroundStyle(FWColor.textBody)
                .fixedSize(horizontal: false, vertical: true)
                .frame(minHeight: FWSpace.touchChild, alignment: .center)
        }
        .accessibilityElement(children: .combine)
    }
}
