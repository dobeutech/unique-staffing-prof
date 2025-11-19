import { useTheme } from 'next-themes'
import { useEffect, useState } from 'react'
import { Moon, Sun, Monitor } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { useLanguage } from '@/contexts/LanguageContext'

export function ThemeToggle() {
  const { theme, setTheme, systemTheme } = useTheme()
  const { t } = useLanguage()
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  const cycleTheme = () => {
    let newTheme: string
    let themeName: string

    if (theme === 'light') {
      newTheme = 'dark'
      themeName = t('theme.dark')
    } else if (theme === 'dark') {
      newTheme = 'system'
      themeName = t('theme.system') || 'System'
    } else {
      newTheme = 'light'
      themeName = t('theme.light')
    }

    setTheme(newTheme)

    const announcement = document.getElementById('theme-announcement')
    if (announcement) {
      announcement.textContent = `${t('accessibility.themeChanged') || 'Theme changed to'} ${themeName}`
    }
  }

  const getCurrentIcon = () => {
    if (!mounted) {
      return <Sun className="h-4 w-4" />
    }

    if (theme === 'system') {
      return <Monitor className="h-4 w-4 transition-transform duration-300" />
    }

    const resolvedTheme = theme === 'system' ? systemTheme : theme

    return (
      <>
        <Sun className={`absolute h-4 w-4 transition-all duration-300 ${
          resolvedTheme === 'dark' ? 'rotate-90 scale-0' : 'rotate-0 scale-100'
        }`} />
        <Moon className={`absolute h-4 w-4 transition-all duration-300 ${
          resolvedTheme === 'dark' ? 'rotate-0 scale-100' : '-rotate-90 scale-0'
        }`} />
      </>
    )
  }

  const getAriaLabel = () => {
    if (!mounted) return t('theme.toggle') || 'Toggle theme'

    if (theme === 'light') return t('theme.light') || 'Light mode'
    if (theme === 'dark') return t('theme.dark') || 'Dark mode'
    return t('theme.system') || 'System mode'
  }

  if (!mounted) {
    return (
      <Button
        variant="ghost"
        size="icon"
        className="relative h-9 w-9"
        disabled
        aria-label={t('theme.toggle')}
      >
        <Sun className="h-4 w-4" />
      </Button>
    )
  }

  return (
    <>
      <Button
        variant="ghost"
        size="icon"
        onClick={cycleTheme}
        className="relative h-9 w-9 transition-colors hover:bg-accent focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
        aria-label={`${getAriaLabel()}. Click to cycle theme modes.`}
        title={`Current: ${getAriaLabel()}. Click to cycle through Light, Dark, and System modes.`}
      >
        {getCurrentIcon()}
        <span className="sr-only">{getAriaLabel()}</span>
      </Button>
      <div
        id="theme-announcement"
        role="status"
        aria-live="polite"
        aria-atomic="true"
        className="sr-only"
      />
    </>
  )
}
