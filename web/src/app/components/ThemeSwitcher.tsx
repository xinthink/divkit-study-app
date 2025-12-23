import { Sun, Moon, Palette, Settings, X } from "lucide-react";
import { useState } from "react";

type Brand = "ocean" | "volcano";
type Theme = "light" | "dark";

interface ThemeSwitcherProps {
  brand: Brand;
  theme: Theme;
  onBrandChange: (brand: Brand) => void;
  onThemeChange: (theme: Theme) => void;
}

export function ThemeSwitcher({ brand, theme, onBrandChange, onThemeChange }: ThemeSwitcherProps) {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <>
      {/* Floating Action Button */}
      <button
        onClick={() => setIsOpen(true)}
        className="fixed top-6 right-6 w-14 h-14 flex items-center justify-center shadow-lg z-50 transition-all duration-300"
        style={{
          backgroundColor: 'var(--color-brand-primary)',
          color: 'var(--color-text-onBrand)',
          borderRadius: 'var(--dim-radius-card)',
          border: 'none',
          cursor: 'pointer'
        }}
        onMouseEnter={(e) => {
          e.currentTarget.style.backgroundColor = 'var(--color-brand-primary-hover)';
        }}
        onMouseLeave={(e) => {
          e.currentTarget.style.backgroundColor = 'var(--color-brand-primary)';
        }}
      >
        <Settings className="w-6 h-6" />
      </button>

      {/* Overlay */}
      {isOpen && (
        <div
          className="fixed inset-0 bg-black transition-opacity duration-300 z-50"
          style={{
            opacity: isOpen ? 0.5 : 0
          }}
          onClick={() => setIsOpen(false)}
        />
      )}

      {/* Drawer */}
      <div
        className="fixed top-0 right-0 h-full w-80 shadow-2xl z-50 transition-transform duration-300"
        style={{
          backgroundColor: 'var(--color-bg-elevated)',
          transform: isOpen ? 'translateX(0)' : 'translateX(100%)',
          borderLeft: '1px solid var(--color-border-default)'
        }}
      >
        {/* Drawer Header */}
        <div
          className="flex items-center justify-between p-6"
          style={{
            borderBottom: '1px solid var(--color-border-default)'
          }}
        >
          <h2
            style={{
              color: 'var(--color-text-primary)',
              fontFamily: 'var(--font-family-heading)',
              transition: 'color 0.3s ease'
            }}
          >
            Settings
          </h2>
          <button
            onClick={() => setIsOpen(false)}
            className="w-10 h-10 flex items-center justify-center transition-all duration-300"
            style={{
              backgroundColor: 'var(--color-bg-surface)',
              color: 'var(--color-text-primary)',
              borderRadius: 'var(--dim-radius-button)',
              border: 'none',
              cursor: 'pointer'
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.backgroundColor = 'var(--color-bg-input)';
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.backgroundColor = 'var(--color-bg-surface)';
            }}
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Drawer Content */}
        <div className="p-6 space-y-6">
          {/* Brand Switcher */}
          <div>
            <div 
              className="flex items-center gap-2 mb-3"
              style={{
                color: 'var(--color-text-secondary)',
                fontFamily: 'var(--font-family-body)',
                transition: 'color 0.3s ease'
              }}
            >
              <Palette className="w-4 h-4" />
              <span>Brand</span>
            </div>
            <div className="flex gap-2">
              <button
                onClick={() => onBrandChange("ocean")}
                className="flex-1 px-4 py-3 transition-all duration-300"
                style={{
                  backgroundColor: brand === "ocean" ? 'var(--color-brand-primary)' : 'var(--color-bg-surface)',
                  color: brand === "ocean" ? 'var(--color-text-onBrand)' : 'var(--color-text-primary)',
                  borderRadius: 'var(--dim-radius-button)',
                  border: brand === "ocean" ? 'none' : '1px solid var(--color-border-default)',
                  fontFamily: 'var(--font-family-body)',
                  cursor: 'pointer'
                }}
              >
                Ocean
              </button>
              <button
                onClick={() => onBrandChange("volcano")}
                className="flex-1 px-4 py-3 transition-all duration-300"
                style={{
                  backgroundColor: brand === "volcano" ? 'var(--color-brand-primary)' : 'var(--color-bg-surface)',
                  color: brand === "volcano" ? 'var(--color-text-onBrand)' : 'var(--color-text-primary)',
                  borderRadius: 'var(--dim-radius-button)',
                  border: brand === "volcano" ? 'none' : '1px solid var(--color-border-default)',
                  fontFamily: 'var(--font-family-body)',
                  cursor: 'pointer'
                }}
              >
                Volcano
              </button>
            </div>
            <p
              className="mt-2 text-sm"
              style={{
                color: 'var(--color-text-tertiary)',
                fontFamily: 'var(--font-family-body)',
                transition: 'color 0.3s ease'
              }}
            >
              {brand === "ocean" 
                ? "Ocean: Calm tech style, deep blue theme, subtle rounded corners" 
                : "Volcano: Energetic youthful style, orange-red theme, capsule rounded corners"}
            </p>
          </div>

          {/* Theme Switcher */}
          <div>
            <div 
              className="flex items-center gap-2 mb-3"
              style={{
                color: 'var(--color-text-secondary)',
                fontFamily: 'var(--font-family-body)',
                transition: 'color 0.3s ease'
              }}
            >
              {theme === "light" ? <Sun className="w-4 h-4" /> : <Moon className="w-4 h-4" />}
              <span>Theme</span>
            </div>
            <div className="flex gap-2">
              <button
                onClick={() => onThemeChange("light")}
                className="flex-1 px-4 py-3 transition-all duration-300"
                style={{
                  backgroundColor: theme === "light" ? 'var(--color-brand-primary)' : 'var(--color-bg-surface)',
                  color: theme === "light" ? 'var(--color-text-onBrand)' : 'var(--color-text-primary)',
                  borderRadius: 'var(--dim-radius-button)',
                  border: theme === "light" ? 'none' : '1px solid var(--color-border-default)',
                  fontFamily: 'var(--font-family-body)',
                  cursor: 'pointer'
                }}
              >
                Light
              </button>
              <button
                onClick={() => onThemeChange("dark")}
                className="flex-1 px-4 py-3 transition-all duration-300"
                style={{
                  backgroundColor: theme === "dark" ? 'var(--color-brand-primary)' : 'var(--color-bg-surface)',
                  color: theme === "dark" ? 'var(--color-text-onBrand)' : 'var(--color-text-primary)',
                  borderRadius: 'var(--dim-radius-button)',
                  border: theme === "dark" ? 'none' : '1px solid var(--color-border-default)',
                  fontFamily: 'var(--font-family-body)',
                  cursor: 'pointer'
                }}
              >
                Dark
              </button>
            </div>
          </div>

          {/* Current Mode Display */}
          <div 
            className="p-4"
            style={{
              backgroundColor: 'var(--color-bg-surface)',
              borderRadius: 'var(--dim-radius-card)',
              border: '1px solid var(--color-border-default)',
              transition: 'all 0.3s ease'
            }}
          >
            <div className="text-sm mb-2" style={{ 
              color: 'var(--color-text-secondary)',
              fontFamily: 'var(--font-family-body)'
            }}>
              Current Configuration
            </div>
            <div style={{ 
              color: 'var(--color-text-primary)',
              fontFamily: 'var(--font-family-body)',
              transition: 'color 0.3s ease'
            }}>
              <div className="flex items-center justify-between mb-1">
                <span className="text-sm">Brand:</span>
                <span>{brand === "ocean" ? "Ocean" : "Volcano"}</span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-sm">Theme:</span>
                <span>{theme === "light" ? "Light" : "Dark"}</span>
              </div>
            </div>
          </div>

          {/* Info Section */}
          <div 
            className="p-4"
            style={{
              backgroundColor: 'var(--color-brand-secondary)',
              borderRadius: 'var(--dim-radius-card)',
              transition: 'all 0.3s ease'
            }}
          >
            <p className="text-sm" style={{ 
              color: 'var(--color-text-primary)',
              fontFamily: 'var(--font-family-body)'
            }}>
              💡 Design Token system supports real-time multi-brand and multi-theme switching. All visual elements are managed through semantic tokens.
            </p>
          </div>
        </div>
      </div>
    </>
  );
}