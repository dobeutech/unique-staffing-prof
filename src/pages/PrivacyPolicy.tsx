import { useLanguage } from "@/contexts/LanguageContext"
import { Link } from "react-router-dom"
import { ArrowLeft } from "lucide-react"
import { Button } from "@/components/ui/button"

export function PrivacyPolicy() {
  const { t } = useLanguage()

  const sections = [
    { key: 'dataCollection', title: t('privacy.dataCollection.title'), content: t('privacy.dataCollection.content') },
    { key: 'cookieTracking', title: t('privacy.cookieTracking.title'), content: t('privacy.cookieTracking.content') },
    { key: 'thirdPartySharing', title: t('privacy.thirdPartySharing.title'), content: t('privacy.thirdPartySharing.content') },
    { key: 'dataRetention', title: t('privacy.dataRetention.title'), content: t('privacy.dataRetention.content') },
    { key: 'yourRights', title: t('privacy.yourRights.title'), content: t('privacy.yourRights.content') },
    { key: 'optOut', title: t('privacy.optOut.title'), content: t('privacy.optOut.content') },
    { key: 'emailCommunications', title: t('privacy.emailCommunications.title'), content: t('privacy.emailCommunications.content') },
    { key: 'smsCommunications', title: t('privacy.smsCommunications.title'), content: t('privacy.smsCommunications.content') },
    { key: 'contactUs', title: t('privacy.contactUs.title'), content: t('privacy.contactUs.content') },
  ]

  return (
    <div className="min-h-screen bg-background">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12 lg:py-16">
        <Link to="/">
          <Button variant="ghost" className="mb-8">
            <ArrowLeft className="mr-2 h-4 w-4" />
            Back to Home
          </Button>
        </Link>

        <div className="prose prose-lg max-w-none">
          <h1 className="font-heading font-bold text-4xl text-foreground mb-4">
            {t('privacy.title')}
          </h1>

          <p className="text-muted-foreground mb-8">
            {t('privacy.lastUpdated')}: {new Date().toLocaleDateString()}
          </p>

          <div className="bg-card border border-border rounded-lg p-6 mb-8">
            <p className="text-foreground leading-relaxed">
              {t('privacy.introduction')}
            </p>
          </div>

          {sections.map((section) => (
            <div key={section.key} className="mb-8">
              <h2 className="font-heading font-bold text-2xl text-foreground mb-4">
                {section.title}
              </h2>
              <p className="text-foreground/80 leading-relaxed whitespace-pre-line">
                {section.content}
              </p>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
