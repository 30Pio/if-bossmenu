import { createRoot } from 'react-dom/client';
import App from './components/App';
import './index.scss';
import '@mantine/core/styles.css';
import '@mantine/charts/styles.css';
import '@mantine/notifications/styles.css';
import { MantineProvider } from '@mantine/core';
import { Notifications } from '@mantine/notifications';

createRoot(document.getElementById('root') as HTMLElement).render(
  <MantineProvider><Notifications /><App /></MantineProvider>
);