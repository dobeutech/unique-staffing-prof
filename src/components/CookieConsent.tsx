import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Card } from "@/components/ui/card"
import { X, Cookie } from "lucide-react"
import { Link } from "react-router-dom"
import { useLanguage } from "@/contexts/LanguageContext"

type ConsentStatus = "pending" | "accepted" | "rejected" | "customized"

interface ConsentPreferences {
  essential: boolean
  analytics: boolean
  marketing: boolean
}

const CONSENT_KEY = "cookie_consent"
const PREFERENCES_KEY = "cookie_preferences"

export function CookieConsent() {
  const { t } = useLanguage()
  const [visible, setVisible] = useState(false)
  const [showDetails, setShowDetails] = useState(false)
  const [preferences, setPreferences] = useState<ConsentPreferences>({
    essential: true,
    analytics: false,
    marketing: false
  })

  useEffect(() => {
    const consent = localStorage.getItem(CONSENT_KEY)
    if (!consent) {
      // Small delay for better UX
      const timer = setTimeout(() => setVisible(true), 1000)
      return () => clearTimeout(timer)
    } else {
      // Load saved preferences
      const savedPrefs = localStorage.getItem(PREFERENCES_KEY)
      if (savedPrefs) {
        setPreferences(JSON.parse(savedPrefs))
      }
    }
  }, [])

  const saveConsent = (status: ConsentStatus, prefs: ConsentPreferences) => {
    localStorage.setItem(CONSENT_KEY, status)
    localStorage.setItem(PREFERENCES_KEY, JSON.stringify(prefs))
    setPreferences(prefs)
    setVisible(false)

    // Dispatch event for analytics integration
    window.dispatchEvent(new CustomEvent("cookieConsentUpdate", {
      detail: { status, preferences: prefs }
    }))

    // Initialize analytics if accepted
    if (prefs.analytics && typeof window !== "undefined") {
      initializeAnalytics()
    }
  }

  const initializeAnalytics = () => {
    // Google Analytics initialization will be handled here
    // This is where GA4 would be enabled based on consent
    console.log("Analytics enabled")
  }

  const handleAcceptAll = () => {
    saveConsent("accepted", {
      essential: true,
      analytics: true,
      marketing: true
    })
  }

  const handleRejectNonEssential = () => {
    saveConsent("rejected", {
      essential: true,
      analytics: false,
      marketing: false
    })
  }

  const handleSavePreferences = () => {
    saveConsent("customized", preferences)
  }

  const handleDoNotSell = () => {
    // CCPA "Do Not Sell My Personal Information" compliance
    saveConsent("rejected", {
      essential: true,
      analytics: false,
      marketing: false
    })
  }

  if (!visible) return null

  return (
    <div className="fixed bottom-0 left-0 right-0 z-50 p-4 sm:p-6">
      <Card className="max-w-4xl mx-auto p-4 sm:p-6 shadow-lg border-border bg-card">
        <div className="flex flex-col gap-4">
          <div className="flex items-start justify-between gap-4">
            <div className="flex items-start gap-3">
              <Cookie className="h-6 w-6 text-primary flex-shrink-0 mt-0.5" />
              <div>
                <h3 className="font-heading font-semibold text-lg text-foreground mb-2">
                  {t('cookieConsent.title')}
                </h3>
                <p className="text-sm text-muted-foreground leading-relaxed">
                  {t('cookieConsent.description')}{" "}
                  <Link to="/privacy" className="text-primary hover:underline">
                    {t('cookieConsent.learnMore')}
                  </Link>
                </p>
              </div>
            </div>
            <button
              onClick={() => setVisible(false)}
              className="text-muted-foreground hover:text-foreground"
              aria-label={t('accessibility.close')}
            >
              <X size={20} />
            </button>
          </div>

          {showDetails && (
            <div className="border-t border-border pt-4 space-y-3">
              <div className="flex items-center justify-between">
                <div>
                  <p className="font-medium text-sm">{t('cookieConsent.necessary')}</p>
                  <p className="text-xs text-muted-foreground">{t('cookieConsent.necessaryDesc')}</p>
                </div>
                <input
                  type="checkbox"
                  checked={preferences.essential}
                  disabled
                  className="h-4 w-4"
                />
              </div>
              <div className="flex items-center justify-between">
                <div>
                  <p className="font-medium text-sm">{t('cookieConsent.analytics')}</p>
                  <p className="text-xs text-muted-foreground">{t('cookieConsent.analyticsDesc')}</p>
                </div>
                <input
                  type="checkbox"
                  checked={preferences.analytics}
                  onChange={(e) => setPreferences({ ...preferences, analytics: e.target.checked })}
                  className="h-4 w-4"
                />
              </div>
              <div className="flex items-center justify-between">
                <div>
                  <p className="font-medium text-sm">{t('cookieConsent.marketing')}</p>
                  <p className="text-xs text-muted-foreground">{t('cookieConsent.marketingDesc')}</p>
                </div>
                <input
                  type="checkbox"
                  checked={preferences.marketing}
                  onChange={(e) => setPreferences({ ...preferences, marketing: e.target.checked })}
                  className="h-4 w-4"
                />
              </div>
            </div>
          )}

          <div className="flex flex-col sm:flex-row items-center justify-between gap-3 pt-2">
            <div className="flex items-center gap-2 text-xs">
              <button
                onClick={() => setShowDetails(!showDetails)}
                className="text-primary hover:underline"
              >
                {showDetails ? t('cookieConsent.hideDetails') : t('cookieConsent.customize')}
              </button>
              <span className="text-muted-foreground">|</span>
              <button
                onClick={handleDoNotSell}
                className="text-primary hover:underline"
              >
                {t('cookieConsent.doNotSell')}
              </button>
            </div>
            <div className="flex items-center gap-2">
              {showDetails ? (
                <Button
                  variant="outline"
                  size="sm"
                  onClick={handleSavePreferences}
                >
                  {t('cookieConsent.save')}
                </Button>
              ) : (
                <Button
                  variant="outline"
                  size="sm"
                  onClick={handleRejectNonEssential}
                >
                  {t('cookieConsent.rejectAll')}
                </Button>
              )}
              <Button size="sm" onClick={handleAcceptAll}>
                {t('cookieConsent.acceptAll')}
              </Button>
            </div>
          </div>
        </div>
      </Card>
    </div>
  )
}
