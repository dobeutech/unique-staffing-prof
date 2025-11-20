import { Button } from "@/components/ui/button"
import { ArrowRight } from "@phosphor-icons/react"
import { useLanguage } from "@/contexts/LanguageContext"
import { motion } from "framer-motion"

export function Hero() {
  const { t } = useLanguage()

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.15,
        delayChildren: 0.2
      }
    }
  }

  const itemVariants = {
    hidden: { opacity: 0, y: 30 },
    visible: {
      opacity: 1,
      y: 0,
      transition: {
        duration: 0.6,
        ease: [0.25, 0.1, 0.25, 1] as const
      }
    }
  }

  const statsVariants = {
    hidden: { opacity: 0, scale: 0.8 },
    visible: {
      opacity: 1,
      scale: 1,
      transition: {
        duration: 0.5,
        ease: [0.25, 0.1, 0.25, 1] as const
      }
    }
  }
  const scrollToSection = (id: string) => {
    const element = document.getElementById(id)
    if (element) {
      element.scrollIntoView({ behavior: "smooth" })
    }
  }

  return (
    <section
      id="hero"
      className="relative pt-32 lg:pt-40 pb-16 lg:pb-24 bg-gradient-to-br from-primary/5 via-background to-secondary/30"
    >
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <motion.div
          className="max-w-4xl mx-auto text-center"
          initial="hidden"
          animate="visible"
          variants={containerVariants}
        >
          <motion.h1
            className="font-heading font-bold text-4xl sm:text-5xl lg:text-6xl text-foreground tracking-tight mb-6"
            variants={itemVariants}
          >
            {t('hero.title')}
          </motion.h1>
          <motion.p
            className="text-lg lg:text-xl text-foreground/80 mb-10 max-w-3xl mx-auto leading-relaxed"
            variants={itemVariants}
          >
            {t('hero.subtitle')}
          </motion.p>
          <motion.div
            className="flex flex-col sm:flex-row gap-4 justify-center items-center"
            variants={itemVariants}
          >
            <Button
              size="lg"
              className="text-base px-8 py-6 h-auto group"
              onClick={() => scrollToSection("apply")}
            >
              {t('nav.apply')}
              <ArrowRight className="ml-2 group-hover:translate-x-1 transition-transform" />
            </Button>
            <Button
              size="lg"
              variant="outline"
              className="text-base px-8 py-6 h-auto bg-background hover:bg-secondary"
              onClick={() => scrollToSection("contact")}
            >
              {t('hero.ctaEmployers')}
            </Button>
          </motion.div>
        </motion.div>

        <motion.div
          className="mt-20 grid grid-cols-2 lg:grid-cols-4 gap-8 max-w-5xl mx-auto"
          initial="hidden"
          animate="visible"
          variants={{
            hidden: { opacity: 0 },
            visible: {
              opacity: 1,
              transition: {
                staggerChildren: 0.1,
                delayChildren: 0.8
              }
            }
          }}
        >
          <motion.div className="text-center" variants={statsVariants}>
            <div className="font-heading font-bold text-3xl lg:text-4xl text-primary mb-2">
              15+
            </div>
            <div className="text-sm lg:text-base text-muted-foreground">
              {t('hero.yearsExperience')}
            </div>
          </motion.div>
          <motion.div className="text-center" variants={statsVariants}>
            <div className="font-heading font-bold text-3xl lg:text-4xl text-primary mb-2">
              500+
            </div>
            <div className="text-sm lg:text-base text-muted-foreground">
              {t('hero.companiesServed')}
            </div>
          </motion.div>
          <motion.div className="text-center" variants={statsVariants}>
            <div className="font-heading font-bold text-3xl lg:text-4xl text-primary mb-2">
              5,000+
            </div>
            <div className="text-sm lg:text-base text-muted-foreground">
              {t('hero.placementsMade')}
            </div>
          </motion.div>
          <motion.div className="text-center" variants={statsVariants}>
            <div className="font-heading font-bold text-3xl lg:text-4xl text-primary mb-2">
              98%
            </div>
            <div className="text-sm lg:text-base text-muted-foreground">
              {t('hero.clientSatisfaction')}
            </div>
          </motion.div>
        </motion.div>
      </div>
    </section>
  )
}
