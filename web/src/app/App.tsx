import { useState, useEffect } from "react";
import { LoginPage } from "./components/LoginPage";
import { ThemeSwitcher } from "./components/ThemeSwitcher";

type Brand = "ocean" | "volcano";
type Theme = "light" | "dark";

export default function App() {
  const [brand, setBrand] = useState<Brand>("ocean");
  const [theme, setTheme] = useState<Theme>("light");

  // Apply data attributes to document root
  useEffect(() => {
    document.documentElement.setAttribute("data-brand", brand);
    document.documentElement.setAttribute("data-theme", theme);
  }, [brand, theme]);

  return (
    <div className="relative">
      {/* Theme Switcher Controls */}
      <ThemeSwitcher
        brand={brand}
        theme={theme}
        onBrandChange={setBrand}
        onThemeChange={setTheme}
      />

      {/* Mobile Banking Login Page */}
      <div className="max-w-md mx-auto">
        <LoginPage />
      </div>
    </div>
  );
}