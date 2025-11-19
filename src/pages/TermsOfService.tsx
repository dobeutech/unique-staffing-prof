import { useLanguage } from "@/contexts/LanguageContext"
import { Link } from "react-router-dom"
import { ArrowLeft } from "lucide-react"
import { Button } from "@/components/ui/button"

export function TermsOfService() {
  const { t } = useLanguage()

  const sections = [
    { key: 'acceptance', title: t('terms.acceptance.title'), content: t('terms.acceptance.content') },
    { key: 'services', title: t('terms.services.title'), content: t('terms.services.content') },
    { key: 'userResponsibilities', title: t('terms.userResponsibilities.title'), content: t('terms.userResponsibilities.content') },
    { key: 'dataUsage', title: t('terms.dataUsage.title'), content: t('terms.dataUsage.content') },
    { key: 'intellectualProperty', title: t('terms.intellectualProperty.title'), content: t('terms.intellectualProperty.content') },
    { key: 'limitationOfLiability', title: t('terms.limitationOfLiability.title'), content: t('terms.limitationOfLiability.content') },
    { key: 'modifications', title: t('terms.modifications.title'), content: t('terms.modifications.content') },
    { key: 'governingLaw', title: t('terms.governingLaw.title'), content: t('terms.governingLaw.content') },
    { key: 'contactUs', title: t('terms.contactUs.title'), content: t('terms.contactUs.content') },
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
            {t('terms.title')}
          </h1>

          <p className="text-muted-foreground mb-8">
            {t('terms.lastUpdated')}: {new Date().toLocaleDateString()}
          </p>

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
