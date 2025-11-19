import { Card } from "@/components/ui/card"
import { Sparkles, Users, ShoppingCart, Phone, Factory, MapPin } from "lucide-react"

const regions = [
  { name: "Washington D.C.", abbr: "DC" },
  { name: "Maryland", abbr: "MD" },
  { name: "Virginia", abbr: "VA" },
  { name: "Illinois", abbr: "IL" },
  { name: "Ohio", abbr: "OH" },
  { name: "New Jersey", abbr: "NJ" }
]

const industries = [
  {
    icon: Sparkles,
    title: "Janitorial",
    description: "Professional cleaning and maintenance"
  },
  {
    icon: Users,
    title: "Human Resources",
    description: "Staffing and recruitment solutions"
  },
  {
    icon: ShoppingCart,
    title: "Retail & Sales",
    description: "Customer-facing positions"
  },
  {
    icon: Phone,
    title: "Call Center",
    description: "Customer service specialists"
  },
  {
    icon: Factory,
    title: "Industrial",
    description: "Manufacturing and warehouse"
  }
]

export function Industries() {
  return (
    <section id="industries" className="py-16 lg:py-24 bg-secondary/30">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="font-heading font-bold text-3xl lg:text-4xl text-foreground mb-4">
            Where We Serve
          </h2>
          <div className="flex items-center justify-center gap-2 mb-4">
            <MapPin className="text-primary" size={20} />
            <p className="text-lg font-semibold text-foreground">
              Serving Washington D.C., Maryland, Virginia, Illinois, Ohio, and New Jersey
            </p>
          </div>
          <p className="text-base text-muted-foreground max-w-2xl mx-auto">
            Professional staffing solutions across five key industries
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-5 gap-6 lg:gap-8">
          {industries.map((industry, index) => {
            const Icon = industry.icon
            return (
              <Card
                key={index}
                className="p-6 text-center hover:shadow-md transition-all duration-300 hover:-translate-y-1 border-border bg-card"
              >
                <div className="w-16 h-16 mx-auto rounded-full bg-primary/10 flex items-center justify-center mb-4">
                  <Icon size={32} className="text-primary" />
                </div>
                <h3 className="font-heading font-semibold text-lg text-foreground mb-2">
                  {industry.title}
                </h3>
                <p className="text-sm text-muted-foreground">
                  {industry.description}
                </p>
              </Card>
            )
          })}
        </div>
      </div>
    </section>
  )
}
