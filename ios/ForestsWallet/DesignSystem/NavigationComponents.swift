import SwiftUI

struct NavHeader<Action: View>: View {
    var title: String
    var subtitle: String? = nil
    var size: FWControlSize = .child
    var onBack: (() -> Void)? = nil
    @ViewBuilder var action: () -> Action

    init(
        title: String,
        subtitle: String? = nil,
        size: FWControlSize = .child,
        onBack: (() -> Void)? = nil,
        @ViewBuilder action: @escaping () -> Action
    ) {
        self.title = title
        self.subtitle = subtitle
        self.size = size
        self.onBack = onBack
        self.action = action
    }

    var body: some View {
        HStack(spacing: FWSpace.s4) {
            if let onBack {
                FWIconButton(icon: .chevronLeft, label: "返回", size: size == .child ? .parent : .small, bare: true, action: onBack)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(FWType.rounded(size.titleSize, weight: .heavy))
                    .foregroundStyle(FWColor.textStrong)
                    .lineLimit(1)
                if let subtitle {
                    Text(subtitle)
                        .font(FWType.text(size.captionSize, weight: .regular))
                        .foregroundStyle(FWColor.textMuted)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            action()
        }
        .frame(minHeight: size == .child ? 64 : 52)
        .accessibilityElement(children: .contain)
    }
}

extension NavHeader where Action == EmptyView {
    init(title: String, subtitle: String? = nil, size: FWControlSize = .child, onBack: (() -> Void)? = nil) {
        self.init(title: title, subtitle: subtitle, size: size, onBack: onBack) { EmptyView() }
    }
}

struct NavItem: Identifiable, Hashable {
    var id: String
    var label: String
    var icon: FWGlyph
}

struct FWSidebar: View {
    var items: [NavItem]
    var active: String
    var brand: String = "Forrest's Wallet"
    var onSelect: (String) -> Void
    var footer: AnyView? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: FWSpace.s7) {
            Text(brand)
                .font(FWType.rounded(22, weight: .black))
                .tracking(-0.4)
                .foregroundStyle(FWColor.honey500)
                .padding(.horizontal, FWSpace.s3)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: FWSpace.s2) {
                ForEach(items) { item in
                    let on = item.id == active
                    Button {
                        onSelect(item.id)
                    } label: {
                        HStack(spacing: FWSpace.s4) {
                            FWIcon(glyph: item.icon, size: 24)
                            Text(item.label)
                                .font(FWType.rounded(FWType.childLabel, weight: on ? .heavy : .semibold))
                            Spacer(minLength: 0)
                        }
                        .foregroundStyle(on ? FWColor.paper000 : FWColor.textOnInkMuted)
                        .padding(.horizontal, FWSpace.s4)
                        .frame(minHeight: FWSpace.touchChild)
                        .background(
                            RoundedRectangle(cornerRadius: FWRadius.lg, style: .continuous)
                                .fill(on ? FWColor.sidebarActive : .clear)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(on ? [.isSelected] : [])
                    .accessibilityIdentifier("nav.\(item.id)")
                }
            }

            Spacer(minLength: 0)
            if let footer {
                footer
            }
        }
        .padding(.vertical, FWSpace.s8)
        .padding(.horizontal, FWSpace.s5)
        .frame(width: FWSpace.sidebarWidth, alignment: .topLeading)
        .frame(maxHeight: .infinity)
        .background(FWColor.surfaceInk.ignoresSafeArea())
        .accessibilityIdentifier("sidebar")
    }
}

struct FWTabBar: View {
    var items: [NavItem]
    var active: String
    var center: String? = nil
    var onSelect: (String) -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(items) { item in
                let on = item.id == active
                let isCenter = center == item.id
                Button {
                    onSelect(item.id)
                } label: {
                    VStack(spacing: 3) {
                        ZStack {
                            if isCenter {
                                RoundedRectangle(cornerRadius: FWRadius.md, style: .continuous)
                                    .fill(FWColor.actionAccent)
                                    .fwCardShadow(child: false)
                            }
                            FWIcon(glyph: item.icon, size: isCenter ? 26 : 24, weight: (on || isCenter) ? .semibold : .medium)
                        }
                        .frame(width: isCenter ? 46 : 30, height: isCenter ? 46 : 30)
                        .foregroundStyle(
                            isCenter ? FWColor.actionAccentText : on ? FWColor.spruce700 : FWColor.textFaint
                        )

                        Text(item.label)
                            .font(FWType.rounded(11, weight: on ? .heavy : .semibold))
                            .foregroundStyle(
                                isCenter ? FWColor.actionAccentText : on ? FWColor.spruce700 : FWColor.textFaint
                            )
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: FWSpace.touchParent)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(item.label)
                .accessibilityAddTraits(on ? [.isSelected] : [])
                .accessibilityIdentifier("tab.\(item.id)")
            }
        }
        .padding(.horizontal, FWSpace.s3)
        .padding(.top, 6)
        .padding(.bottom, 10)
        .background(FWColor.surfaceCard.ignoresSafeArea(edges: .bottom))
        .overlay(alignment: .top) {
            Rectangle().fill(FWColor.borderHair).frame(height: 1)
        }
        .accessibilityIdentifier("tabbar")
    }
}
