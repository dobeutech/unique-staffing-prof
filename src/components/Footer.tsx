import { Phone, Mail, MapPin, MessageSquare, Printer } from "lucide-react"

export function Footer() {
  const scrollToSection = (id: string) => {
    const element = document.getElementById(id)
    if (element) {
      element.scrollIntoView({ behavior: "smooth" })
    }
  }

  return (
    <footer className="bg-primary text-primary-foreground">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 lg:py-16">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8 lg:gap-12">
          <div className="lg:col-span-2">
            <h3 className="font-heading font-bold text-2xl mb-4">
              Unique Staffing Professionals Inc.
            </h3>
            <p className="text-primary-foreground/80 mb-4 leading-relaxed">
              Where Opportunity Starts! Expanding access to meaningful employment across the globe
              through innovative staffing solutions and local partnerships.
            </p>
            <p className="text-primary-foreground/70 text-sm mb-6">
              Led by CEO Otniel Morilla
            </p>
            <div className="flex gap-4">
              <a href="tel:+13012385182" className="text-primary-foreground hover:text-accent transition-colors" aria-label="Call us">
                <Phone size={24} />
              </a>
              <a href="mailto:info@uniquestaffingprofessionals.com" className="text-primary-foreground hover:text-accent transition-colors" aria-label="Email us">
                <Mail size={24} />
              </a>
              <a href="sms:+13012385183" className="text-primary-foreground hover:text-accent transition-colors" aria-label="Text us">
                <MessageSquare size={24} />
              </a>
            </div>
          </div>

          <div>
            <h4 className="font-heading font-semibold text-lg mb-4">Quick Links</h4>
            <ul className="space-y-2">
              <li>
                <button
                  onClick={() => scrollToSection("services")}
                  className="text-primary-foreground/80 hover:text-primary-foreground transition-colors"
                >
                  Services
                </button>
              </li>
              <li>
                <button
                  onClick={() => scrollToSection("industries")}
                  className="text-primary-foreground/80 hover:text-primary-foreground transition-colors"
                >
                  Industries
                </button>
              </li>
              <li>
                <button
                  onClick={() => scrollToSection("about")}
                  className="text-primary-foreground/80 hover:text-primary-foreground transition-colors"
                >
                  About Us
                </button>
              </li>
              <li>
                <button
                  onClick={() => scrollToSection("contact")}
                  className="text-primary-foreground/80 hover:text-primary-foreground transition-colors"
                >
                  Contact
                </button>
              </li>
            </ul>
          </div>

          <div>
            <h4 className="font-heading font-semibold text-lg mb-4">Contact Info</h4>
            <ul className="space-y-3 text-primary-foreground/80 text-sm">
              <li className="flex items-start gap-2">
                <MapPin size={18} className="flex-shrink-0 mt-0.5" />
                <span>6200 Baltimore Avenue<br />Floor 3, Suite R35<br />Riverdale, MD 20737</span>
              </li>
              <li className="flex items-center gap-2">
                <Phone size={18} />
                <a href="tel:+13012385182" className="hover:text-primary-foreground transition-colors">
                  (301) 238-5182
                </a>
              </li>
              <li className="flex items-center gap-2">
                <MessageSquare size={18} />
                <a href="sms:+13012385183" className="hover:text-primary-foreground transition-colors">
                  Text: 1 (301) 238-5183
                </a>
              </li>
              <li className="flex items-center gap-2">
                <Printer size={18} />
                <span>Fax: (240) 392-3898</span>
              </li>
              <li className="flex items-center gap-2">
                <Mail size={18} />
                <a href="mailto:info@uniquestaffingprofessionals.com" className="hover:text-primary-foreground transition-colors break-all">
                  info@uniquestaffingprofessionals.com
                </a>
              </li>
            </ul>
          </div>
        </div>

        <div className="border-t border-primary-foreground/20 mt-12 pt-8 text-center text-primary-foreground/60 text-sm">
          <p>&copy; {new Date().getFullYear()} Unique Staffing Professionals Inc. All rights reserved.</p>
        </div>
      </div>
    </footer>
  )
}
