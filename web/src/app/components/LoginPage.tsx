import { useState } from "react";
import { Eye, EyeOff, Lock, Mail, Fingerprint } from "lucide-react";

export function LoginPage() {
  const [showPassword, setShowPassword] = useState(false);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
    // Mock login logic
    console.log("Login attempt with:", { email, password });
  };

  return (
    <div className="min-h-screen flex flex-col" style={{ 
      backgroundColor: 'var(--color-bg-canvas)',
      transition: 'background-color 0.3s ease'
    }}>
      {/* Header with logo */}
      <div className="px-6 pt-16 pb-8">
        <div 
          className="w-16 h-16 flex items-center justify-center mb-4"
          style={{
            backgroundColor: 'var(--color-brand-primary)',
            borderRadius: 'var(--dim-radius-card)',
            transition: 'all 0.3s ease'
          }}
        >
          <Lock className="w-8 h-8" style={{ color: 'var(--color-text-onBrand)' }} />
        </div>
        <h1 
          className="mt-6 mb-2"
          style={{
            color: 'var(--color-text-primary)',
            fontFamily: 'var(--font-family-heading)',
            transition: 'color 0.3s ease'
          }}
        >
          Welcome Back
        </h1>
        <p 
          style={{
            color: 'var(--color-text-secondary)',
            fontFamily: 'var(--font-family-body)',
            transition: 'color 0.3s ease'
          }}
        >
          Sign in to your account to continue
        </p>
      </div>

      {/* Login Form */}
      <div className="flex-1 px-6">
        <form onSubmit={handleLogin} className="space-y-5">
          {/* Email Input */}
          <div>
            <label 
              htmlFor="email" 
              className="block mb-2"
              style={{
                color: 'var(--color-text-primary)',
                fontFamily: 'var(--font-family-body)',
                transition: 'color 0.3s ease'
              }}
            >
              Email
            </label>
            <div className="relative">
              <div 
                className="absolute left-4 top-1/2 -translate-y-1/2 pointer-events-none"
                style={{ color: 'var(--color-text-tertiary)' }}
              >
                <Mail className="w-5 h-5" />
              </div>
              <input
                id="email"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="your@email.com"
                className="w-full pl-12 pr-4 py-4 outline-none transition-all duration-300"
                style={{
                  backgroundColor: 'var(--color-bg-input)',
                  color: 'var(--color-text-primary)',
                  borderRadius: 'var(--dim-radius-input)',
                  border: '1px solid var(--color-border-input)',
                  fontFamily: 'var(--font-family-body)'
                }}
                onFocus={(e) => {
                  e.target.style.borderColor = 'var(--color-border-focus)';
                }}
                onBlur={(e) => {
                  e.target.style.borderColor = 'var(--color-border-input)';
                }}
              />
            </div>
          </div>

          {/* Password Input */}
          <div>
            <label 
              htmlFor="password" 
              className="block mb-2"
              style={{
                color: 'var(--color-text-primary)',
                fontFamily: 'var(--font-family-body)',
                transition: 'color 0.3s ease'
              }}
            >
              Password
            </label>
            <div className="relative">
              <div 
                className="absolute left-4 top-1/2 -translate-y-1/2 pointer-events-none"
                style={{ color: 'var(--color-text-tertiary)' }}
              >
                <Lock className="w-5 h-5" />
              </div>
              <input
                id="password"
                type={showPassword ? "text" : "password"}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Enter your password"
                className="w-full pl-12 pr-12 py-4 outline-none transition-all duration-300"
                style={{
                  backgroundColor: 'var(--color-bg-input)',
                  color: 'var(--color-text-primary)',
                  borderRadius: 'var(--dim-radius-input)',
                  border: '1px solid var(--color-border-input)',
                  fontFamily: 'var(--font-family-body)'
                }}
                onFocus={(e) => {
                  e.target.style.borderColor = 'var(--color-border-focus)';
                }}
                onBlur={(e) => {
                  e.target.style.borderColor = 'var(--color-border-input)';
                }}
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-4 top-1/2 -translate-y-1/2"
                style={{ color: 'var(--color-text-tertiary)' }}
              >
                {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
              </button>
            </div>
          </div>

          {/* Forgot Password Link */}
          <div className="flex justify-end">
            <button
              type="button"
              style={{
                color: 'var(--color-brand-primary)',
                fontFamily: 'var(--font-family-body)',
                transition: 'color 0.3s ease'
              }}
              onMouseEnter={(e) => {
                e.currentTarget.style.color = 'var(--color-brand-primary-hover)';
              }}
              onMouseLeave={(e) => {
                e.currentTarget.style.color = 'var(--color-brand-primary)';
              }}
            >
              Forgot Password?
            </button>
          </div>

          {/* Login Button */}
          <button
            type="submit"
            className="w-full py-4 transition-all duration-300"
            style={{
              backgroundColor: 'var(--color-brand-primary)',
              color: 'var(--color-text-onBrand)',
              borderRadius: 'var(--dim-radius-button)',
              fontFamily: 'var(--font-family-body)',
              border: 'none',
              cursor: 'pointer'
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.backgroundColor = 'var(--color-brand-primary-hover)';
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.backgroundColor = 'var(--color-brand-primary)';
            }}
            onMouseDown={(e) => {
              e.currentTarget.style.backgroundColor = 'var(--color-brand-primary-active)';
            }}
            onMouseUp={(e) => {
              e.currentTarget.style.backgroundColor = 'var(--color-brand-primary-hover)';
            }}
          >
            Sign In
          </button>

          {/* Divider */}
          <div className="relative py-4">
            <div 
              className="absolute inset-0 flex items-center"
            >
              <div 
                className="w-full border-t"
                style={{ borderColor: 'var(--color-border-default)' }}
              />
            </div>
            <div className="relative flex justify-center">
              <span 
                className="px-4"
                style={{
                  backgroundColor: 'var(--color-bg-canvas)',
                  color: 'var(--color-text-tertiary)',
                  fontFamily: 'var(--font-family-body)',
                  transition: 'all 0.3s ease'
                }}
              >
                OR
              </span>
            </div>
          </div>

          {/* Biometric Login Button */}
          <button
            type="button"
            className="w-full py-4 flex items-center justify-center gap-3 transition-all duration-300"
            style={{
              backgroundColor: 'var(--color-bg-surface)',
              color: 'var(--color-text-primary)',
              borderRadius: 'var(--dim-radius-button)',
              border: '1px solid var(--color-border-default)',
              fontFamily: 'var(--font-family-body)',
              cursor: 'pointer'
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.backgroundColor = 'var(--color-bg-elevated)';
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.backgroundColor = 'var(--color-bg-surface)';
            }}
          >
            <Fingerprint className="w-5 h-5" />
            Sign in with Biometrics
          </button>
        </form>
      </div>

      {/* Sign Up Link */}
      <div className="px-6 py-8 text-center">
        <p style={{ 
          color: 'var(--color-text-secondary)',
          fontFamily: 'var(--font-family-body)',
          transition: 'color 0.3s ease'
        }}>
          Don't have an account?{' '}
          <button
            type="button"
            style={{
              color: 'var(--color-brand-primary)',
              fontFamily: 'var(--font-family-body)',
              background: 'none',
              border: 'none',
              cursor: 'pointer',
              transition: 'color 0.3s ease'
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.color = 'var(--color-brand-primary-hover)';
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.color = 'var(--color-brand-primary)';
            }}
          >
            Sign Up
          </button>
        </p>
      </div>
    </div>
  );
}