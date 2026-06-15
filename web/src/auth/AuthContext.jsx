import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
} from "react";
import {
  fetchCurrentUser,
  login as loginRequest,
  logout as logoutRequest,
} from "../services/authApi.js";

const TOKEN_KEY = "josi_auth_token";
const USER_KEY = "josi_auth_user";

const AuthContext = createContext(null);

function readStoredUser() {
  try {
    const rawUser = window.localStorage.getItem(USER_KEY);
    return rawUser ? JSON.parse(rawUser) : null;
  } catch {
    return null;
  }
}

function writeDashboardCookie(token) {
  const secure = window.location.protocol === "https:" ? "; Secure" : "";
  if (!token) {
    document.cookie = `josi_auth_token=; Max-Age=0; Path=/; SameSite=Lax${secure}`;
    return;
  }

  document.cookie = `josi_auth_token=${encodeURIComponent(
    token,
  )}; Path=/; SameSite=Lax${secure}`;
}

export function AuthProvider({ children }) {
  const [token, setToken] = useState(() =>
    window.localStorage.getItem(TOKEN_KEY),
  );
  const [user, setUser] = useState(readStoredUser);
  const [isRestoring, setIsRestoring] = useState(Boolean(token));

  const persistSession = useCallback((nextToken, nextUser) => {
    setToken(nextToken);
    setUser(nextUser);
    if (nextToken) {
      window.localStorage.setItem(TOKEN_KEY, nextToken);
      window.localStorage.setItem(USER_KEY, JSON.stringify(nextUser));
      writeDashboardCookie(nextToken);
      return;
    }

    window.localStorage.removeItem(TOKEN_KEY);
    window.localStorage.removeItem(USER_KEY);
    writeDashboardCookie(null);
  }, []);

  useEffect(() => {
    if (!token) {
      setIsRestoring(false);
      return;
    }

    let isActive = true;
    setIsRestoring(true);
    fetchCurrentUser(token)
      .then(({ data }) => {
        if (!isActive) {
          return;
        }
        persistSession(token, data.user);
      })
      .catch(() => {
        if (isActive) {
          persistSession(null, null);
        }
      })
      .finally(() => {
        if (isActive) {
          setIsRestoring(false);
        }
      });

    return () => {
      isActive = false;
    };
  }, [persistSession, token]);

  const login = useCallback(
    async ({ emailOrPhone, password }) => {
      const { data } = await loginRequest({
        email_or_phone: emailOrPhone,
        password,
      });
      const nextToken = data.token || data.access_token;
      persistSession(nextToken, data.user);
      return data;
    },
    [persistSession],
  );

  const saveSession = useCallback(
    ({ token: nextToken, access_token: accessToken, user: nextUser }) => {
      persistSession(nextToken || accessToken, nextUser);
    },
    [persistSession],
  );

  const logout = useCallback(async () => {
    const currentToken = token;
    persistSession(null, null);
    if (currentToken) {
      await logoutRequest(currentToken).catch(() => {});
    }
  }, [persistSession, token]);

  const value = useMemo(
    () => ({
      token,
      user,
      isAuthenticated: Boolean(token && user),
      isRestoring,
      login,
      logout,
      saveSession,
    }),
    [isRestoring, login, logout, saveSession, token, user],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth must be used within AuthProvider.");
  }

  return context;
}
