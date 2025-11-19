import { BrowserRouter as Router, Routes, Route } from "react-router-dom"
import { AuthProvider } from "@/contexts/AuthContext"
import { BusinessInfoProvider } from "@/contexts/BusinessInfoContext"
import { ThemeProvider } from "@/contexts/ThemeProvider"
import { LanguageProvider } from "@/contexts/LanguageContext"
import { ProtectedRoute } from "@/components/ProtectedRoute"
import { Home } from "@/pages/Home"
import { ServiceAreaPage } from "@/pages/ServiceAreaPage"
import { AdminLogin } from "@/pages/AdminLogin"
import { AdminDashboard } from "@/pages/AdminDashboard"
import { ApplicationConfirmation } from "@/pages/ApplicationConfirmation"
import { EmailVerification } from "@/pages/EmailVerification"
import { PrivacyPolicy } from "@/pages/PrivacyPolicy"
import { TermsOfService } from "@/pages/TermsOfService"
import { Unsubscribe } from "@/pages/Unsubscribe"
import { OpenAPIDocs } from "@/pages/OpenAPIDocs"
import { Toaster } from "@/components/ui/sonner"
import { CookieConsent } from "@/components/CookieConsent"

function App() {
  return (
    <ThemeProvider>
      <LanguageProvider>
        <AuthProvider>
          <BusinessInfoProvider>
            <Router>
              <Routes>
                <Route path="/" element={<Home />} />
                <Route path="/service-area/:city" element={<ServiceAreaPage />} />
                <Route path="/application-confirmation" element={<ApplicationConfirmation />} />
                <Route path="/verify-email" element={<EmailVerification />} />
                <Route path="/privacy" element={<PrivacyPolicy />} />
                <Route path="/terms" element={<TermsOfService />} />
                <Route path="/unsubscribe" element={<Unsubscribe />} />
                <Route path="/openapi/docs" element={<OpenAPIDocs />} />
                <Route path="/admin/login" element={<AdminLogin />} />
                <Route
                  path="/admin/dashboard"
                  element={
                    <ProtectedRoute>
                      <AdminDashboard />
                    </ProtectedRoute>
                  }
                />
              </Routes>
              <Toaster />
              <CookieConsent />
            </Router>
          </BusinessInfoProvider>
        </AuthProvider>
      </LanguageProvider>
    </ThemeProvider>
  )
}

export default App
