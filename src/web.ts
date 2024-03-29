import { WebPlugin } from '@capacitor/core';

import type { htmltodataPlugin } from './definitions';

export class htmltodataWeb extends WebPlugin implements htmltodataPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
  async htmlstringToBase64(options: { value: string }): Promise<{ value: string }> {
    return options;
  }
  async printDefaultiOS(options: { value: string }): Promise<{ value: string }> {
    return options;
  }

}
