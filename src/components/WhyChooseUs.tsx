import { Card } from "@/components/ui/card"
import { Zap, Heart, Shield, Users, Lightbulb, Handshake, Target, Award, Clock, Bus, GraduationCap, TrendingUp } from "lucide-react"

const coreValues = [
  {
    icon: Zap,
    title: "Empowerment",
    description: "Equipping individuals with opportunities to thrive and succeed."
  },
  {
    icon: Heart,
    title: "Community Impact",
    description: "Making a positive difference in the communities we serve."
  },
  {
    icon: Shield,
    title: "Integrity",
    description: "Upholding honesty and ethical standards in all we do."
  },
  {
    icon: Users,
    title: "Inclusivity",
    description: "Embracing diversity and creating opportunities for all."
  },
  {
    icon: Lightbulb,
    title: "Innovation",
    description: "Continuously improving our staffing solutions and services."
  },
  {
    icon: Handshake,
    title: "Collaboration",
    description: "Building strong partnerships with clients and candidates."
  },
  {
    icon: Target,
    title: "Resilience",
    description: "Adapting and overcoming challenges to deliver results."
  },
  {
    icon: Award,
    title: "Service Excellence",
    description: "Committed to delivering outstanding service quality."
  }
]

const keyFeatures = [
  {
    icon: Clock,
    title: "24/7 Application Portal",
    description: "Apply anytime, anywhere through our convenient online system."
  },
  {
    icon: Bus,
    title: "Transportation Services",
    description: "We help ensure reliable transportation for our workforce."
  },
  {
    icon: GraduationCap,
    title: "Safety Training",
    description: "Comprehensive training programs to keep everyone safe."
  },
  {
    icon: TrendingUp,
    title: "Performance Bonuses",
    description: "Rewarding excellence and dedication in the workplace."
  }
]

export function WhyChooseUs() {
  return (
    <section id="about" className="py-16 lg:py-24 bg-background">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid lg:grid-cols-2 gap-12 lg:gap-16 items-center">
          <div>
            <h2 className="font-heading font-bold text-3xl lg:text-4xl text-foreground mb-6">
              Why Choose Unique Staffing Professionals Inc.?
            </h2>
            <p className="text-lg text-foreground/80 mb-6 leading-relaxed">
              Led by CEO Otniel Morilla, we are committed to expanding access to meaningful employment
              through innovative staffing solutions and local partnerships.
            </p>
            <p className="text-base text-muted-foreground leading-relaxed mb-8">
              Our community-focused approach combines comprehensive employment solutions with
              dedicated support services including transportation assistance, safety training programs,
              and performance incentives. We believe in empowering individuals and building bridges
              between talent and opportunity.
            </p>
            <div className="space-y-4 mb-8">
              <h3 className="font-heading font-semibold text-xl text-foreground">Key Features</h3>
              <div className="grid grid-cols-2 gap-4">
                {keyFeatures.map((feature, index) => {
                  const Icon = feature.icon
                  return (
                    <div key={index} className="flex gap-3">
                      <div className="w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center flex-shrink-0">
                        <Icon size={20} className="text-primary" />
                      </div>
                      <div>
                        <div className="font-medium text-sm text-foreground">{feature.title}</div>
                        <div className="text-xs text-muted-foreground">{feature.description}</div>
                      </div>
                    </div>
                  )
                })}
              </div>
            </div>
          </div>

          <div>
            <h3 className="font-heading font-semibold text-xl text-foreground mb-6">Our Core Values</h3>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            {coreValues.map((feature, index) => {
              const Icon = feature.icon
              return (
                <Card
                  key={index}
                  className="p-5 border-border bg-card hover:shadow-md transition-shadow"
                >
                  <div className="w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center mb-3">
                    <Icon size={20} className="text-primary" />
                  </div>
                  <h4 className="font-heading font-semibold text-base text-foreground mb-1">
                    {feature.title}
                  </h4>
                  <p className="text-xs text-muted-foreground leading-relaxed">
                    {feature.description}
                  </p>
                </Card>
              )
            })}
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}
