// Apex Class: DeltaExportSettingsController.cls
public with sharing class DeltaExportSettingsController {
    // Method to get current settings
    @AuraEnabled(cacheable=true)
    public static ExportSettings__mdt getSettings() {
        // Replace with actual logic to retrieve settings
        List<ExportSettings__mdt> settingsList = [SELECT Id, SelectedObjects__c, ExportFrequency__c, FileFormats__c, StorageOption__c FROM ExportSettings__mdt LIMIT 1];
        if (!settingsList.isEmpty()) {
            return settingsList[0];
        } else {
            return null;
        }
    }

    // Method to save settings
    @AuraEnabled
    public static void saveSettings(String selectedObjects, String exportFrequency, String fileFormats, String storageOption) {
        ExportSettings__mdt settings = new ExportSettings__mdt(
            SelectedObjects__c = selectedObjects,
            ExportFrequency__c = exportFrequency,
            FileFormats__c = fileFormats,
            StorageOption__c = storageOption
        );

        // Upsert settings (create or update)
        upsert settings;
    }
}
