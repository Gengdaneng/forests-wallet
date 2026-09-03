import SwiftUI

struct ParentSettingsView: View {
    @Environment(SampleWalletStore.self) private var store
    @Environment(ParentNav.self) private var nav
    @State private var pinSheet = false
    @State private var pin = ""
    @State private var pinError = false

    var body: some View {
        let snap = store.snapshot
        VStack(alignment: .leading, spacing: FWSpace.s5) {
            FWScreenTitle(text: "设置", size: .parent)

            FWCard {
                VStack(alignment: .leading, spacing: 0) {
                    Text("已配对的设备")
                        .font(FWType.rounded(FWType.head, weight: .bold))
                        .foregroundStyle(FWColor.textStrong)
                        .padding(.bottom, FWSpace.s3)

                    ForEach(snap.devices) { device in
                        HStack(spacing: 12) {
                            FWIcon(glyph: device.glyph, size: 20)
                                .foregroundStyle(FWColor.spruce600)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(device.name)
                                    .font(FWType.text(FWType.body, weight: .semibold))
                                    .foregroundStyle(FWColor.textStrong)
                                Text(device.roleLabel)
                                    .font(FWType.text(FWType.caption, weight: .regular))
                                    .foregroundStyle(FWColor.textMuted)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            if !device.isThisDevice {
                                FWButton(title: "撤销", tone: .quiet, size: .small) {
                                    store.revokeDevice(id: device.id)
                                }
                            }
                        }
                        .frame(minHeight: FWSpace.touchParent)
                        .overlay(alignment: .bottom) {
                            Rectangle().fill(FWColor.borderHair).frame(height: 1)
                        }
                    }

                    VStack(alignment: .leading, spacing: FWSpace.s3) {
                        FWButton(title: "添加设备（生成配对码）", tone: .primary, icon: .plus, block: true) {
                            _ = store.generatePairingCode()
                            nav.pairingSheet = true
                        }
                        .accessibilityIdentifier("settings.pair")
                        Text("6 位数字 · 10 分钟过期 · 用一次即作废")
                            .font(FWType.text(FWType.caption, weight: .regular))
                            .foregroundStyle(FWColor.textMuted)
                    }
                    .padding(.top, FWSpace.s4)
                }
            }

            FWCard {
                VStack(spacing: 0) {
                    FWToggle(
                        label: "周日结算提醒",
                        hint: "只发给爸爸。Forrest 的 iPad 上一条通知都不会有。",
                        isOn: Binding(
                            get: { store.sundayReminder },
                            set: { store.setSundayReminder($0) }
                        )
                    )
                    FWToggle(
                        label: "预览儿童视图需要 PIN",
                        hint: "PIN 只保护这个入口，权限仍由服务端强制",
                        isOn: Binding(
                            get: { store.previewNeedsPIN },
                            set: { store.setPreviewNeedsPIN($0) }
                        )
                    )
                    FWToggle(
                        label: "假装离线（样例）",
                        hint: "本地样例状态，用来看不能记账时的提示。",
                        isOn: Binding(
                            get: { !store.isOnline },
                            set: { store.setOnline(!$0) }
                        )
                    )
                }
            }

            FWCard(tone: .sunken) {
                VStack(spacing: FWSpace.s3) {
                    FWButton(title: "预览 Forrest 看到的画面", tone: .outline, icon: .eye, block: true) {
                        if store.previewNeedsPIN {
                            pin = ""
                            pinError = false
                            pinSheet = true
                        } else {
                            nav.previewChild = true
                        }
                    }
                    FWButton(title: "规则清单", tone: .outline, icon: .scrollText, block: true, action: { nav.showRules = true })
                    FWButton(title: "重新配对", tone: .outline, icon: .rotateCcw, block: true) {
                        store.resetPairing()
                    }
                }
            }

            StatusBanner(kind: .norealmoney, text: "这个 App 只记录数字，不接触银行卡、也不转移现金", size: .parent)
        }
        .sheet(isPresented: $pinSheet) {
            VStack(alignment: .leading, spacing: FWSpace.s5) {
                Text("输入 PIN")
                    .font(FWType.rounded(FWType.title, weight: .heavy))
                    .foregroundStyle(FWColor.textStrong)
                Text("PIN 只保护预览入口。样例 PIN 是 \(SampleData.previewPIN)。")
                    .font(FWType.text(FWType.body, weight: .regular))
                    .foregroundStyle(FWColor.textMuted)
                DigitHero(value: pin, label: "4 位数字", accessibilityName: "PIN")
                NumberPad(value: $pin, maxDigits: 4)
                if pinError {
                    StatusBanner(kind: .failed, text: "PIN 不对", size: .parent)
                }
                FWButton(title: "打开预览", tone: .primary, block: true, disabled: pin.count < 4) {
                    if pin == SampleData.previewPIN {
                        pinSheet = false
                        nav.previewChild = true
                    } else {
                        pinError = true
                    }
                }
            }
            .padding(FWSpace.s5)
            .fwScreenBackground()
            .presentationDetents([.large])
        }
        .accessibilityIdentifier("screen.parent.settings")
    }
}

struct ParentPairingCodeSheet: View {
    @Environment(SampleWalletStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: FWSpace.s5) {
            Text("给 Forrest 的配对码")
                .font(FWType.rounded(FWType.title, weight: .heavy))
                .foregroundStyle(FWColor.textStrong)
            Text(store.pairingCode ?? SampleData.pairingCode)
                .font(FWType.rounded(56, weight: .black))
                .monospacedDigit()
                .foregroundStyle(FWColor.spruce700)
                .tracking(8)
                .accessibilityIdentifier("pairing.code")
            Text("6 位数字 · 10 分钟过期 · 用一次即作废")
                .font(FWType.text(FWType.body, weight: .regular))
                .foregroundStyle(FWColor.textMuted)
                .multilineTextAlignment(.center)
            StatusBanner(kind: .norealmoney, text: "在 iPad 上输入这些数字就能看账本，不能记账", size: .parent)
            FWButton(title: "好", tone: .primary, block: true) { dismiss() }
        }
        .padding(FWSpace.s6)
        .fwScreenBackground()
    }
}
