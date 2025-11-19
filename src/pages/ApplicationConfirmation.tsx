import { useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { Card } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Alert, AlertDescription } from '@/components/ui/alert'
import { CheckCircle, Mail, ArrowLeft } from 'lucide-react'

export function ApplicationConfirmation() {
  const navigate = useNavigate()

  useEffect(() => {
    window.scrollTo(0, 0)
  }, [])

  return (
    <div className="min-h-screen bg-background py-16">
      <div className="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8">
        <Card className="p-8 lg:p-12 text-center space-y-6">
          <div className="flex justify-center">
            <div className="h-20 w-20 rounded-full bg-success/20 flex items-center justify-center">
              <CheckCircle className="h-10 w-10 text-success" />
            </div>
          </div>

          <div className="space-y-3">
            <h1 className="font-heading font-bold text-3xl text-foreground">
              Application Received!
            </h1>
            <p className="text-lg text-muted-foreground">
              Thank you for submitting your application to Unique Staffing Professionals.
            </p>
          </div>

          <Alert>
            <Mail className="h-4 w-4" />
            <AlertDescription>
              <strong>Important:</strong> Please check your email inbox for a verification link.
              You must verify your email address to complete your application submission.
            </AlertDescription>
          </Alert>

          <div className="space-y-4 text-left bg-muted p-6 rounded-lg">
            <h2 className="font-semibold text-lg">What happens next?</h2>
            <ol className="space-y-3 text-sm text-muted-foreground list-decimal list-inside">
              <li>
                Check your email for a verification link (check spam/junk if you don't see it)
              </li>
              <li>
                Click the verification link to confirm your email address
              </li>
              <li>
                Once verified, your application will be reviewed by our team
              </li>
              <li>
                We'll contact you within 3-5 business days regarding next steps
              </li>
            </ol>
          </div>

          <div className="pt-4 space-y-3">
            <Button
              onClick={() => navigate('/')}
              className="w-full sm:w-auto"
            >
              <ArrowLeft className="mr-2 h-4 w-4" />
              Back to Home
            </Button>

            <p className="text-sm text-muted-foreground">
              Questions? Contact us at{' '}
              <a
                href="mailto:omorilla@uniquestaffingprofessionals.com"
                className="text-primary hover:underline"
              >
                omorilla@uniquestaffingprofessionals.com
              </a>
            </p>
          </div>
        </Card>
      </div>
    </div>
  )
}
