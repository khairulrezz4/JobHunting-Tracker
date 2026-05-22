' Job Tracker - Excel Report Generator
' VBS Script to convert CSV to formatted Excel workbook

Option Explicit
Dim objExcel, objWorkbook, objSheet, objFSO, csvFile, excelFile
Dim arrLines, arrFields, rowIndex, colIndex
Dim objRange, objTable, strTableName

' Get command line arguments
If WScript.Arguments.Count < 2 Then
    WScript.Echo "Usage: cscript generate-excel.vbs <csv_file> <output_file>"
    WScript.Quit 1
End If

csvFile = WScript.Arguments(0)
excelFile = WScript.Arguments(1)

' Create file system object
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Verify CSV file exists
If Not objFSO.FileExists(csvFile) Then
    WScript.Echo "Error: CSV file not found: " & csvFile
    WScript.Quit 1
End If

' Create Excel application
On Error Resume Next
Set objExcel = CreateObject("Excel.Application")
If Err.Number <> 0 Then
    WScript.Echo "Error: Excel is not installed"
    WScript.Quit 1
End If
On Error GoTo 0

' Create new workbook
Set objWorkbook = objExcel.Workbooks.Add()
Set objSheet = objWorkbook.Sheets(1)
objSheet.Name = "Job Tracker"

' Read CSV file
Dim strCSVContent, arrRows
strCSVContent = objFSO.OpenTextFile(csvFile, 1).ReadAll()
arrRows = Split(strCSVContent, vbCrLf)

' Parse and write CSV data to Excel
rowIndex = 1
For Each Dim strRow In arrRows
    If Len(strRow) > 0 Then
        arrFields = Split(strRow, ",")
        colIndex = 1
        
        Dim strField, cleanField
        For Each strField In arrFields
            ' Remove quotes from fields
            cleanField = Replace(strField, """", "")
            objSheet.Cells(rowIndex, colIndex).Value = cleanField
            colIndex = colIndex + 1
        Next
        
        rowIndex = rowIndex + 1
    End If
Next

' Format header row
With objSheet.Range("1:1")
    .Font.Bold = True
    .Interior.Color = RGB(0, 102, 204)
    .Font.Color = RGB(255, 255, 255)
    .HorizontalAlignment = -4108 ' xlCenter
    .VerticalAlignment = -4127 ' xlMiddle
End With

' Auto-fit columns
objSheet.Columns("A:H").AutoFit

' Set column widths for better readability
objSheet.Columns(1).ColumnWidth = 8  ' ID
objSheet.Columns(2).ColumnWidth = 25 ' Job Name
objSheet.Columns(3).ColumnWidth = 25 ' Title
objSheet.Columns(4).ColumnWidth = 20 ' Company
objSheet.Columns(5).ColumnWidth = 12 ' Status
objSheet.Columns(6).ColumnWidth = 20 ' Date Added
objSheet.Columns(7).ColumnWidth = 20 ' Last Updated
objSheet.Columns(8).ColumnWidth = 30 ' Notes

' Add alternating row colors (light gray)
Dim rowCount, i
rowCount = objSheet.UsedRange.Rows.Count
For i = 2 To rowCount
    If i Mod 2 = 0 Then
        objSheet.Range("A" & i & ":H" & i).Interior.Color = RGB(242, 242, 242)
    End If
Next

' Add table format (if Excel version supports it)
On Error Resume Next
If rowCount > 1 Then
    Set objRange = objSheet.Range("A1:H" & rowCount)
    Set objTable = objSheet.ListObjects.Add(1, objRange, , 1) ' xlSrcRange = 1
    If Err.Number = 0 Then
        objTable.TableStyle = "TableStyleMedium2"
    End If
End If
On Error GoTo 0

' Add data validation for Status column (if data exists)
On Error Resume Next
If rowCount > 1 Then
    Set objRange = objSheet.Range("E2:E" & rowCount)
    With objRange.Validation
        .Type = 3 ' xlList
        .Formula1 = "Pending,Rejected,Approved"
        .IgnoreBlank = True
        .InCellDropdown = True
    End With
End If
On Error GoTo 0

' Protect sheet (optional - comment out if not needed)
' objSheet.Protect "password", True, True, True

' Save workbook
On Error Resume Next
objWorkbook.SaveAs excelFile, 51 ' 51 = xlOpenXMLWorkbook (.xlsx format)
If Err.Number <> 0 Then
    WScript.Echo "Error: Failed to save Excel file: " & excelFile
    objWorkbook.Close False
    objExcel.Quit
    WScript.Quit 1
End If
On Error GoTo 0

' Close workbook and Excel
objWorkbook.Close False
objExcel.Quit

' Cleanup
Set objSheet = Nothing
Set objWorkbook = Nothing
Set objExcel = Nothing
Set objFSO = Nothing

WScript.Echo "Success: Excel report created at " & excelFile
WScript.Quit 0
