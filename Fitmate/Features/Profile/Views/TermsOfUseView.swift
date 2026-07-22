//
//  TermsOfUseView.swift
//  Fitmate
//
//  Created by Akan Akysh on 22/07/26.
//

import SwiftUI

struct TermsOfUseView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var router: Router

    var body: some View {
        VStack(spacing: 0) {
            navigationBar

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Условия использования приложения")
                        .headline24Bold()
                        .foregroundStyle(Color.appBlack)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Дата вступления в силу: [указать дату]")
                        Text("Разработчик: ИП Шимкаев (Казахстан)")
                        Text("Контакт: shimkayev@gmail.com")
                    }
                    .body15Regular()
                    .foregroundStyle(Color.appBlack)

                    Text("Используя приложение Fitmate, вы подтверждаете согласие с настоящими условиями. Если вы не согласны с ними — пожалуйста, не используйте приложение.")
                        .body15Regular()
                        .foregroundStyle(Color.appBlack)

                    ForEach(Self.sections) { section in
                        sectionView(section)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .environment(\.openURL, OpenURLAction { url in
            if url.absoluteString == "fitmate://privacy" {
                router.navigate(to: .privacyPolicy)
            }
            return .handled
        })
    }

    // MARK: - Navigation Bar

    private var navigationBar: some View {
        VStack(spacing: 0) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()
        }
    }

    // MARK: - Section

    private func sectionView(_ section: TermsSection) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(section.title)
                .body17Semibold()
                .foregroundStyle(Color.appBlack)

            if let text = section.text {
                Text(text)
                    .body15Regular()
                    .foregroundStyle(Color.appBlack)
            }

            ForEach(section.bullets) { bullet in
                bulletView(bullet)
            }
        }
    }

    private func bulletView(_ bullet: Bullet) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                Text("•")
                Text(bullet.attributedText)
            }
            .body15Regular()
            .foregroundStyle(Color.appBlack)
            .padding(.leading, 8)

            ForEach(bullet.subBullets, id: \.self) { sub in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                    Text(sub)
                }
                .body15Regular()
                .foregroundStyle(Color.appBlack)
                .padding(.leading, 32)
            }
        }
    }

    // MARK: - Content

    private struct TermsSection: Identifiable {
        var id: String { title }
        let title: String
        var text: String?
        var bullets: [Bullet] = []
    }

    private struct Bullet: Identifiable {
        var id: String { text }
        let text: String
        var subBullets: [String] = []
        var hasPrivacyLink = false

        var attributedText: AttributedString {
            guard hasPrivacyLink else { return AttributedString(text) }
            var result = AttributedString(text)
            var link = AttributedString("Политику конфиденциальности")
            link.underlineStyle = .single
            link.foregroundColor = .appBlack
            link.link = URL(string: "fitmate://privacy")
            return result + link + AttributedString(".")
        }
    }

    private static let sections: [TermsSection] = [
        TermsSection(
            title: "1. Описание сервиса",
            bullets: [
                Bullet(
                    text: "Fitmate — это мобильное приложение для отслеживания фитнес-прогресса. Основной функционал включает:",
                    subBullets: [
                        "отслеживание прогресса в силовых упражнениях",
                        "создание собственных упражнений"
                    ]
                )
            ]
        ),
        TermsSection(
            title: "2. Регистрация и данные",
            bullets: [
                Bullet(
                    text: "Для использования приложения требуется авторизация через Google. Мы собираем:",
                    subBullets: ["адрес электронной почты"]
                ),
                Bullet(text: "Подробнее см. ", hasPrivacyLink: true)
            ]
        ),
        TermsSection(
            title: "3. Платный доступ",
            text: "Приложение предоставляет доступ на платной основе. Условия оплаты и доступные тарифы указываются при оформлении подписки. Мы оставляем за собой право изменять цену или модель монетизации с уведомлением пользователей."
        ),
        TermsSection(
            title: "4. Медицинский дисклеймер",
            text: "Fitmate не является медицинским приложением. Все рекомендации по тренировкам носят информационный и ориентировочный характер. Перед началом любой физической активности рекомендуется проконсультироваться с врачом."
        ),
        TermsSection(
            title: "5. Пользовательский контент",
            text: "Вы можете добавлять свои упражнения, веса и другие данные. Вы несёте личную ответственность за точность введённой информации. Мы оставляем за собой право удалять явно вредоносный или нарушающий закон контент."
        ),
        TermsSection(
            title: "6. Ограничение ответственности",
            text: "Мы не гарантируем отсутствие ошибок или бесперебойную работу сервиса. Fitmate предоставляется «как есть» без явных или подразумеваемых гарантий. Разработчик не несёт ответственности за возможный вред, косвенно связанный с использованием приложения."
        ),
        TermsSection(
            title: "8. Применимое право",
            text: "Все споры регулируются в соответствии с законодательством Республики Казахстан. В случае разногласий стороны стремятся урегулировать их путём переговоров."
        )
    ]
}

#Preview {
    TermsOfUseView()
        .environmentObject(Router())
}
