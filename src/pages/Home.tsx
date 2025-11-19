import { useNavigate } from "react-router-dom"
import { Navigation } from "@/components/Navigation"
import { Hero } from "@/components/Hero"
import { Services } from "@/components/Services"
import { Industries } from "@/components/Industries"
import { WhyChooseUs } from "@/components/WhyChooseUs"
import { EnhancedApplyForm } from "@/components/EnhancedApplyForm"
import { Testimonials } from "@/components/Testimonials"
import { Contact } from "@/components/Contact"
import { Footer } from "@/components/Footer"
import { JobListings } from "@/components/JobListings"
import { TalentNetworkModal } from "@/components/TalentNetworkModal"
import { useBusinessInfo } from "@/contexts/BusinessInfoContext"
import { SEOHead } from "@/components/seo/SEOHead"
import { StructuredData } from "@/components/seo/StructuredData"
import { useLanguage } from "@/contexts/LanguageContext"

export function Home() {
  const navigate = useNavigate()
  const { businessInfo } = useBusinessInfo()
  const { t } = useLanguage()

  const handleApplicationSuccess = () => {
    navigate('/application-confirmation')
  }

  if (!businessInfo) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
      </div>
    )
  }

  return (
    <div className="min-h-screen">
      <a
        href="#main-content"
        className="sr-only focus:not-sr-only"
      >
        {t('accessibility.skipToContent')}
      </a>
      <SEOHead
        businessInfo={businessInfo}
        keywords={[
          "staffing agency Maryland",
          "employment services",
          "job placement Riverdale",
          "temporary staffing",
          "permanent placement",
          "contract staffing",
          "Prince George's County jobs"
        ]}
      />
      <StructuredData businessInfo={businessInfo} type="home" />
      <Navigation />
      <main id="main-content">
        <Hero />
        <Services />
        <Industries />
        <JobListings />
        <WhyChooseUs />
        <EnhancedApplyForm onSuccess={handleApplicationSuccess} />
        <Testimonials />
        <Contact />
      </main>
      <Footer />
      <TalentNetworkModal />
    </div>
  )
}
