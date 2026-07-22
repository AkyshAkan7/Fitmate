//
//  PrivacyPolicyView.swift
//  Fitmate
//
//  Created by Akan Akysh on 22/07/26.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            navigationBar

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Политика конфиденциальности")
                        .headline24Bold()
                        .foregroundStyle(Color.appBlack)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Дата вступления в силу: [указать дату]")
                        Text("Разработчик: ИП Шимкаев (Казахстан)")
                        Text("Контакт: shimkayev@gmail.com")
                    }
                    .body15Regular()
                    .foregroundStyle(Color.appBlack)

                    Text("Мы уважаем вашу конфиденциальность. Ниже указано, какие данные мы собираем и как используем их в приложении Fitmate.")
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

    private func sectionView(_ section: PolicySection) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(section.title)
                .body17Semibold()
                .foregroundStyle(Color.appBlack)

            if let text = section.text {
                Text(text)
                    .body15Regular()
                    .foregroundStyle(Color.appBlack)
            }

            ForEach(section.bullets, id: \.self) { bullet in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                    Text(bullet)
                }
                .body15Regular()
                .foregroundStyle(Color.appBlack)
                .padding(.leading, 8)
            }
        }
    }

    // MARK: - Content

    private struct PolicySection: Identifiable {
        var id: String { title }
        let title: String
        var text: String?
        var bullets: [String] = []
    }

    private static let sections: [PolicySection] = [
        PolicySection(
            title: "1. Какие данные мы собираем",
            bullets: [
                "Через Google-аккаунт: имя, email (для входа и идентификации)",
                "Вводимые вами: возраст, пол, рост, вес, цели тренировок",
                "Автоматически: тип устройства, версия приложения, действия в интерфейсе",
                "Push-уведомления: отправляются только с вашего разрешения (можно отключить в настройках)"
            ]
        ),
        PolicySection(
            title: "2. Зачем мы это используем",
            bullets: [
                "Для входа и персонализации",
                "Для рекомендаций и напоминаний",
                "Для улучшения работы приложения"
            ]
        ),
        PolicySection(
            title: "3. Кому мы передаём данные",
            bullets: [
                "Только проверенным сервисам (например, Google Firebase) — только для хранения и аналитики",
                "Мы не продаём данные и не передаём третьим лицам без законного основания"
            ]
        ),
        PolicySection(
            title: "4. Как защищаем данные",
            bullets: [
                "Используем защищённые соединения (HTTPS)",
                "Храним данные в зашифрованном виде",
                "Соблюдаем минимальный объем хранения"
            ]
        ),
        PolicySection(
            title: "5. Ваши права",
            text: "Вы можете:",
            bullets: [
                "Изменить или удалить свои данные",
                "Удалить аккаунт по запросу на shimkayev@gmail.com"
            ]
        ),
        PolicySection(
            title: "6. Обновления",
            text: "Мы можем вносить изменения в эту политику. Актуальная версия всегда будет доступна в приложении."
        )
    ]
}

#Preview {
    PrivacyPolicyView()
}
