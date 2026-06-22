export type RecordType = "feeding" | "sleep" | "diaper";

export type TodayRecordItem = {
  id: string;
  type: RecordType;
  displayTime: Date;
  sortTime: Date;
  title: string;
  subtitle?: string;
  isOngoing?: boolean;
};
