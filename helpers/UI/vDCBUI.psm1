function vDCBUI {
    [void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
    [xml]$XAML = @'
    <Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="DCB Deployment and Validate Wizard" ResizeMode="NoResize" Height="600" Width="800" WindowStartupLocation="CenterScreen"  >
        <Window.Resources>
        <ControlTemplate x:Key="ErrorTemplate" TargetType="{x:Type Control}">
            <DockPanel>
                <TextBlock Foreground="Red"  TextAlignment="Center" Width="16" FontSize="18" DockPanel.Dock="Right">!</TextBlock>
                <Border BorderThickness="1" BorderBrush="Red">
                    <ScrollViewer x:Name="PART_ContentHost"/>
                </Border>
            </DockPanel>
        </ControlTemplate>
        <ControlTemplate x:Key="NormalTemplate" TargetType="{x:Type Control}">
            <DockPanel>
                <TextBlock Foreground="Red" TextAlignment="Center" Width="16" FontSize="18" DockPanel.Dock="Right"></TextBlock>
                <Border BorderThickness="1" BorderBrush="{DynamicResource {x:Static SystemColors.ControlDarkBrushKey}}">
                    <ScrollViewer x:Name="PART_ContentHost" />
                </Border>
            </DockPanel>
        </ControlTemplate>
        <Style TargetType="{x:Type TextBox}">
            <Setter Property="OverridesDefaultStyle" Value="True" />
            <Setter Property="Template" Value="{DynamicResource ErrorTemplate}" />
        </Style>
        <Style TargetType="{x:Type PasswordBox}">
            <Setter Property="OverridesDefaultStyle" Value="True" />
            <Setter Property="Template" Value="{DynamicResource ErrorTemplate}" />
        </Style>
    </Window.Resources>
    <Grid>
        <StackPanel Name="panel0" HorizontalAlignment="Left" Width="169.149" Background="{DynamicResource {x:Static SystemColors.ControlLightBrushKey}}">
            <Rectangle Height="10" Margin="0,0,159,0" />
            <Grid>
                <Rectangle Name="mark1" Fill="{DynamicResource {x:Static SystemColors.HighlightBrushKey}}" Height="27.976" Margin="0,0,159,0" />
                <Label Content="Introduction" Margin="10,0,0,0"/>
            </Grid>
            <Grid>
                <Rectangle Name="mark3" Fill="{DynamicResource {x:Static SystemColors.HighlightBrushKey}}" Height="27.976" Margin="0,0,159,0" Visibility="Hidden"/>
                <Label Content="Clustes and Nodes" Margin="10,0,0,0"/>
            </Grid>
            <Grid>
                <Rectangle Name="mark4" Fill="{DynamicResource {x:Static SystemColors.HighlightBrushKey}}" Height="27.976" Margin="0,0,159,0" Visibility="Hidden"/>
                <Label Content="Adapters" Margin="10,0,0,0"/>
            </Grid>
            <Grid>
                <Rectangle Name="mark5" Fill="{DynamicResource {x:Static SystemColors.HighlightBrushKey}}" Height="27.976" Margin="0,0,159,0" Visibility="Hidden"/>
                <Label Content="Data Center Bridging" Margin="10,0,0,0"/>
            </Grid>
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="32*"/>
                    <ColumnDefinition Width="38*"/>
                    <ColumnDefinition Width="99*"/>
                </Grid.ColumnDefinitions>
                <Rectangle Name="mark6" Fill="{DynamicResource {x:Static SystemColors.HighlightBrushKey}}" Height="27.976" Margin="0,0,22,0" Visibility="Hidden"/>
                <Label Content="Save and Deploy" Margin="10,0,0,0" Grid.ColumnSpan="3"/>
            </Grid>
        </StackPanel>
        <StackPanel Visibility="Hidden" Name="panel1" HorizontalAlignment="Left" Height="522.101" VerticalAlignment="Top"  Margin="169.149,0,0,0" Width="615.137">
            <TextBlock FontSize="20" Margin="10,0,0,0"><Run Text="Welcome to the Validate-DCB configuration wizard"/></TextBlock>
            <TextBlock Margin="10,0,10,0" TextWrapping="WrapWithOverflow">
                <LineBreak/>
                <Run Text="Before you can Validate your DCB configuration, you must provide some prerequisite information about your expected configuration.  If you already have a configuration file, you can skip this wizard."/>
                <LineBreak/>
                <LineBreak/>
                <Run Text="For additional information on any of these steps, check the "/>
                <Hyperlink Name="uri1" NavigateUri="https://aka.ms/Validate-DCB">Validate-DCB documentation</Hyperlink>.<LineBreak/>
            </TextBlock>
            <TextBlock Margin="10,0,0,0" TextWrapping="WrapWithOverflow">
                    <Run Text="This wizard will help you collect the necessary information:"/>
            </TextBlock>
            <BulletDecorator Margin="10,0,0,0">
                <BulletDecorator.Bullet>
                    <Ellipse Height="5" Width="5" Fill="Black"/>
                </BulletDecorator.Bullet>
                <TextBlock TextWrapping="Wrap" HorizontalAlignment="Left" Margin="19,0,0,0">
                        The hosts or clusters you will be validating
                </TextBlock>
            </BulletDecorator>
            <BulletDecorator Margin="10,0,0,0">
                <BulletDecorator.Bullet>
                    <Ellipse Height="5" Width="5" Fill="Black"/>
                </BulletDecorator.Bullet>
                <TextBlock TextWrapping="Wrap" HorizontalAlignment="Left" Margin="19,0,0,0">
                        Network Adapter Configuration Details
                </TextBlock>
            </BulletDecorator>
            <BulletDecorator Margin="10,0,0,0">
                <BulletDecorator.Bullet>
                    <Ellipse Height="5" Width="5" Fill="Black"/>
                </BulletDecorator.Bullet>
                <TextBlock TextWrapping="Wrap" HorizontalAlignment="Left" Margin="19,0,0,0">
                        Virtual Switch Configuration
                </TextBlock>
            </BulletDecorator>
            <BulletDecorator Margin="10,0,0,0">
                <BulletDecorator.Bullet>
                    <Ellipse Height="5" Width="5" Fill="Black"/>
                </BulletDecorator.Bullet>
                <TextBlock TextWrapping="Wrap" HorizontalAlignment="Left" Margin="19,0,0,0">
                        Virtual Adapter Configuration
                </TextBlock>
            </BulletDecorator>
            <BulletDecorator Margin="10,0,0,0">
                <BulletDecorator.Bullet>
                    <Ellipse Height="5" Width="5" Fill="Black"/>
                </BulletDecorator.Bullet>
                <TextBlock TextWrapping="Wrap" HorizontalAlignment="Left" Margin="19,0,0,0">
                        Priority Flow Control (PFC) and Enhanced Transmission Selection (ETS) settings
                </TextBlock>
            </BulletDecorator>
            <TextBlock Margin="10,0,0,0" TextWrapping="WrapWithOverflow">
                    <LineBreak/>
                    <Run Text="If you experience any issues, please submit an issue on "/>
                    <Hyperlink Name="uri2" NavigateUri="https://aka.ms/Validate-DCB">GitHub</Hyperlink><LineBreak/>
            </TextBlock>
        </StackPanel>
        <StackPanel Visibility="Hidden" Name="panel2" HorizontalAlignment="Left" Height="522.101" VerticalAlignment="Top"  Margin="169.149,0,0,0" Width="615.137">
            <Label Content="lblPlaceHolder1" FontSize="18"  Margin="10,0"/>
            <TextBlock  Margin="14,0" TextWrapping="WrapWithOverflow">
            <LineBreak/>
            <Run Text="This wizard will generate a configuration file that you can use to run Validate-DCB.  You can select an existing file to edit or use one of the templates to base your initial selections off of."/>
            </TextBlock>
            <Grid Margin="0,10"/>
            <Grid Margin="0,2">
                <Label Content="lblPlaceholder2" Margin="10,0,0,0" HorizontalAlignment="Left" Width="130"/>
                <TextBox Name="txtPlaceHolder" Text="" Margin="192.739,0,119.71,0" ></TextBox>
                <Button Name="btnPlaceHolder" Content="Browse..." Margin="0,0,10,0" HorizontalAlignment="Right" Width="104.71" Height="25.426" VerticalAlignment="Bottom"/>
            </Grid>
        </StackPanel>
        <StackPanel Visibility="Hidden" Name="panel3" HorizontalAlignment="Left" Height="522.101" VerticalAlignment="Top" Margin="169.149,0,0,0" Width="615.137">
            <Label Content="Clusters and Nodes" FontSize="18"  Margin="10,0"/>
            <TextBlock  Margin="14,0" TextWrapping="WrapWithOverflow">
                    <Run Text="Enter the clusters or nodes whose configuration you wish to validate.  Any systems specified must have the same configuration for each of the proceeding settings on future pages."/>
            </TextBlock>
            <StackPanel Margin="0,10"/>
            <StackPanel Orientation="Horizontal" Margin="0,2">
                <Grid Margin="0,2">
                    <Label Content="Enter server or cluster name" Margin="10,0,0,0" HorizontalAlignment="Left" Width="180"/>
                    <TextBox Name="txtHostorCluster" Text="" Width="150" Margin="192.739,0,119.71,0" ></TextBox>
                    <Button Name="btnResolveHostorCluster" Content="Resolve" Margin="0,0,10,0" HorizontalAlignment="Right" Width="104.71" Height="25.426" VerticalAlignment="Bottom"/>
                </Grid>
            </StackPanel>
            <StackPanel  Orientation="Horizontal" Margin="0,2" >
                <Label Content="Selected Servers" Margin="10,0,0,0" HorizontalAlignment="Left" Width="182"/>
            </StackPanel>
            <StackPanel Margin="0,10"/>
            <ListView Name="SystemNames" SelectionMode="Single" Height="353" >
                <ListView.View>
                    <GridView>
                        <GridViewColumn Header="System Name" Width="305" DisplayMemberBinding="{Binding SystemName}"/>
                        <GridViewColumn Header="Cluster Name" Width="305" DisplayMemberBinding="{Binding ClusterName}"/>
                    </GridView>
                </ListView.View>
            </ListView>
        </StackPanel>
        <StackPanel Visibility="Hidden" Name="panel4" HorizontalAlignment="Left" Height="522.101" VerticalAlignment="Top" Margin="169.149,0,0,0" Width="615.137">
            <Label Content="Enabled Adapters" FontSize="18"  Margin="10,0"/>
            <TextBlock  Margin="14,0" TextWrapping="WrapWithOverflow"><Run Text="Provide information about the RDMA enabled adapters (required) and virtual switches (optional) that are used for RDMA communication."/></TextBlock>
            <StackPanel Margin="0,5"/>
            <TextBlock  Margin="14,0" TextWrapping="WrapWithOverflow"><Run Text="Enter the details for 1 or more adapters.  If they are attached to a vSwitch, you will need to specify additional options.  In all cases, the Microsoft recommended options are selected by default."/></TextBlock>
            <StackPanel Margin="0,5"/>
            <Grid Margin="0,5"/>
            <Separator/>
            <StackPanel Orientation="Horizontal" Margin="0,2">
                <Label Content="vSwitch Attached" Width="102" />
                <Label Content="vSwitch Name"   Margin="10,0,0,0" Width="122"/>
                <Label Content="Teaming Enabled" Margin="28,0,0,0" Width="100"/>
                <Label Content="vSR-IOV Enabled"  Margin="15,0,0,0" Width="102"/>
                <Label Content="LB Algorithm"  Margin="15,0,0,0" Width="110"/>
            </StackPanel>
            <Separator/>
            <StackPanel Orientation="Horizontal" Margin="33,2,14,2">
                <CheckBox Name="chkvSwAttached" Width="81" VerticalAlignment="Center" IsChecked="False" />
                <TextBox Name="txtvSw1Name" Text="Enable vSwitch" Width="144" Opacity="0.5"/>
                <Label Content="" Margin="35,0,0,0" />
                <CheckBox Name="chkvSw1TeamingEnabled" Width="110" VerticalAlignment="Center" IsChecked="true" Opacity="0.5" />
                <CheckBox Name="chkvSw1SRIOVEnabled" Width="82" VerticalAlignment="Center" IsChecked="true" Opacity="0.5" />
                <ComboBox Name="cmbLBAlgorithm"  Width="100" Opacity="0.5">
                    <ComboBoxItem IsSelected="True">Hyper-V Port</ComboBoxItem>
                    <ComboBoxItem>Dynamic</ComboBoxItem>
                </ComboBox>
            </StackPanel>
            <Separator/>
            <Grid Margin="0,10"/>
            <StackPanel Orientation="Horizontal" Margin="110,2">
                <Label Content="Adapter Name" Width="165" />
                <Label Content="Host vNIC Name"  Width="152"/>
                <Label Content="VLAN" Margin="25,0,0,0" Width="40"/>
            </StackPanel>
            <Separator/>
            <StackPanel Orientation="Horizontal" Margin="95,2" Height="30">
                <Label Content="" Margin="14,0,0,0" HorizontalAlignment="Left" Width="1"/>
                <TextBox Name="txtAdpt1" Text="" Width="150" Height="25"/>
                <Label Content="" Margin="0,0,0,0" HorizontalAlignment="Left" Width="15"/>
                <TextBox Name="txtvSw1vNIC1Name" Text="Enable vSwitch or Team" Width="150" Height="25" Opacity="0.5"/>
                <Label Content="" Margin="0,0,0,0" HorizontalAlignment="Left" Width="30"/>
                <TextBox Name="txtAdpt1VLAN" Text="0" Width="50" Height="25" TextAlignment="Center"/>
            </StackPanel>
            <StackPanel Orientation="Horizontal" Margin="95,2" Height="30">
                <Label Content="" Margin="14,0,0,0" HorizontalAlignment="Left" Width="1"/>
                <TextBox Name="txtAdpt2" Text="" Width="150" Height="25" IsEnabled="true"/>
                <Label Content="" Margin="0,0,0,0" HorizontalAlignment="Left" Width="15"/>
                <TextBox Name="txtvSw1vNIC2Name" Text="Enable vSwitch or Team" Width="150" Height="25" IsEnabled="False" Opacity="0.5"/>
                <Label Content="" Margin="0,0,0,0" HorizontalAlignment="Left" Width="30"/>
                <TextBox Name="txtAdpt2VLAN" Text="0" Width="50" Height="25" IsEnabled="true" TextAlignment="Center"/>
            </StackPanel>
            <StackPanel Orientation="Horizontal" Margin="95,2" Height="30">
                <Label Content="" Margin="14,0,0,0" HorizontalAlignment="Left" Width="1"/>
                <TextBox Name="txtAdpt3" Text="" Width="150" Height="25" IsEnabled="true"/>
                <Label Content="" Margin="0,0,0,0" HorizontalAlignment="Left" Width="15"/>
                <TextBox Name="txtvSw1vNIC3Name" Text="Enable vSwitch or Team" Width="150" Height="25" IsEnabled="False" Opacity="0.5"/>
                <Label Content="" Margin="0,0,0,0" HorizontalAlignment="Left" Width="30"/>
                <TextBox Name="txtAdpt3VLAN" Text="0" Width="50" Height="25" IsEnabled="true" TextAlignment="Center"/>
            </StackPanel>
            <StackPanel Orientation="Horizontal" Margin="95,2" Height="30">
                <Label Content="" Margin="14,0,0,0" HorizontalAlignment="Left" Width="1"/>
                <TextBox Name="txtAdpt4" Text="" Width="150" Height="25" IsEnabled="true"/>
                <Label Content="" Margin="0,0,0,0" HorizontalAlignment="Left" Width="15"/>
                <TextBox Name="txtvSw1vNIC4Name" Text="Enable vSwitch or Team" Width="150" Height="25" IsEnabled="False" Opacity="0.5"/>
                <Label Content="" Margin="0,0,0,0" HorizontalAlignment="Left" Width="30"/>
                <TextBox Name="txtAdpt4VLAN" Text="0" Width="50" Height="25" IsEnabled="true" TextAlignment="Center"/>
            </StackPanel>
            <Separator/>
            <Grid Margin="0,10"/>
            <StackPanel Orientation="Horizontal" Margin="50,2,50,2">
                <Label Content="RDMA Enabled" Width="100" />
                <Label Content="RDMA Type" Width="150" />
                <Label Content="Jumbo Frames"  Margin="0,0,0,0" Width="100"/>
                <Label Content="Encap Overhead" Margin="30,0,0,0" HorizontalAlignment="Left" Width="180"/>
            </StackPanel>
            <StackPanel Orientation="Horizontal" Margin="50,2,80,2">
                <Label Content="" Margin="10,0,0,0" HorizontalAlignment="Left" Width="18"/>
                <CheckBox Name="chkvSw1RDMAEnabled" Content = '' Width="15" VerticalAlignment="Center" IsChecked="True" />
                <Label Content="" Margin="10,0,0,0" HorizontalAlignment="Left" Width="50"/>
                <ComboBox Name="cmbRDMAType" IsEnabled="True" Width="100" Opacity="100">
                    <ComboBoxItem IsSelected="True">iWARP</ComboBoxItem>
                    <ComboBoxItem>RoCE</ComboBoxItem>
                </ComboBox>
                <Label Content="" Margin="10,0,0,0" HorizontalAlignment="Left" Width="40"/>
                <ComboBox Name="cmbvSw1Jumbo"  Width="100" IsEnabled="True">
                    <ComboBoxItem IsSelected="True">9014</ComboBoxItem>
                    <ComboBoxItem>4088</ComboBoxItem>
                    <ComboBoxItem>1514</ComboBoxItem>
                </ComboBox>
                <Label Content="" Margin="10,0,0,0" HorizontalAlignment="Left" Width="42"/>
                <TextBox Name="txtvSw1EncapOverhead" Text="0" Width="50" Height="26" TextAlignment="Center"/>
            </StackPanel>
            <Separator></Separator>
            <Grid Margin="0,5"/>
        </StackPanel>
        <StackPanel Visibility="Hidden" Name="panel5" HorizontalAlignment="Left" Height="522.101" VerticalAlignment="Top"  Margin="169.149,0,0,0" Width="615.137">
            <Label Content="Data Center Bridging" FontSize="18"  Margin="10,0"/>
            <TextBlock  Margin="14,0" TextWrapping="WrapWithOverflow"><Hyperlink Name="uri3" NavigateUri="https://docs.microsoft.com/en-us/windows-server/networking/technologies/dcb/dcb-top"><Run Text="Data Center Bridging (DCB)"/></Hyperlink><Run Text=" "/><Run Text="enables converged fabrics in the data center where compute and storage run on the same network (e.g. HCI) by providing hardware-based bandwidth allocation (ETS) to a specific type of traffic, and enhances Ethernet transport reliability with the use of priority-based flow control (PFC)."/><LineBreak/><LineBreak/><Run Text="If you have chosen iWARP (recommended), or are not using RDMA, DCB is optional.  If you have selected RDMA over Converged Ethernet (RoCE), Data Center Bridging "/><Run FontWeight="Bold" Text="is required "/><Run Text="for network reliability on all NICs and switchports."/></TextBlock>
            <Grid Margin="0,10"/>
            <Separator/>
            <StackPanel Orientation="Horizontal" Margin="0,2">
                <Label Content="Enable DCB:" Margin="2,0,0,0" HorizontalAlignment="Left" Width="80"/>
                <CheckBox Name="chkEnableDCB" Width="27" VerticalAlignment="Center" IsChecked="False" />
                <Label Content="DCB Required:" Margin="10,0,0,0" HorizontalAlignment="Left" Width="90" FontWeight="Bold"/>
                <Label Content="True" Name="lblDCBRequired" Margin="0,0,0,0" HorizontalAlignment="Left" Width="44"/>
                <Label Content="RDMA Enabled:" Margin="5,0,0,0" HorizontalAlignment="Left" Width="100" FontWeight="Bold"/>
                <Label Content="" Margin="0,0,0,0" Name="lblRDMAEnabled" HorizontalAlignment="Left" Width="44"/>
                <Label Content="RDMA Type:" Margin="5,0,0,0" HorizontalAlignment="Left" Width="85" FontWeight="Bold"/>
                <Label Content="" Margin="0,0,0,0" Name="lblRDMAType" HorizontalAlignment="Left" Width="91"/>
            </StackPanel>
            <Separator></Separator>
            <StackPanel Margin="0,10"/>
            <StackPanel Orientation="Horizontal" Margin="35,2">
                <Label Content="Priority" Margin="0,0,0,0" HorizontalAlignment="Left" Width="52"/>
                <Label Content="Policy Name" Margin="15,0,0,0" HorizontalAlignment="Left" Width="127"/>
                <Label Content="Template" Margin="15,0,0,0" HorizontalAlignment="Left" Width="93"/>
                <Label Content="RDMA Port" Margin="0,0,0,0" HorizontalAlignment="Left" Width="86"/>
                <Label Content="Bandwidth Reservation" Margin="0,0,0,0" HorizontalAlignment="Left" Width="137"/>
            </StackPanel>
            <Separator/>
            <StackPanel Orientation="Horizontal" Margin="5,2" Height="30">
                <CheckBox Name="chkDCBClusterEnabled" Width="35" VerticalAlignment="Center" IsEnabled="false" IsChecked="false" Opacity="0.5" />
                <TextBox Name="txtDCBClusterPriority" Text="7" Width="50" Height="25" TextAlignment="Center" IsEnabled="false" Opacity="0.5"/>
                <TextBox Name="txtDCBClusterPolicy" Text="Cluster" Width="117" Height="25" Margin="15,2" IsEnabled="false" Opacity="0.5"/>
                <Label Content="" Margin="0,0,0,0" HorizontalAlignment="Left" Width="15"/>
                <ComboBox Name="cmbClusterTemplate" Width="64" IsEnabled="False" Opacity="0.5">
                    <ComboBoxItem IsSelected="True">Cluster</ComboBoxItem>
                </ComboBox>
                <Label Content="" Margin="0,0,0,0" HorizontalAlignment="Left" Width="25"/>
                <TextBox Name="txtDCBClusterRDMAPort" Text="N/A" Width="80" Height="25" IsEnabled="False" Opacity="0.5" Margin="0,2" TextAlignment="Center"/>
                <Label Content="" Margin="0,0,0,0" HorizontalAlignment="Left" Width="21"/>
                <Label Content="" Margin="0,0,0,0" HorizontalAlignment="Left" Width="21"/>
                <TextBox Name="txtDCBClusterBandwidth" Text="1" Width="57" Height="25" TextAlignment="Center" IsEnabled="False" Opacity=".5"/>
            </StackPanel>
            <StackPanel Orientation="Horizontal" Margin="5,2" Height="30">
                <CheckBox Name="chkDCBSMBEnabled" Width="35" VerticalAlignment="Center" IsEnabled="false" IsChecked="false" Opacity="0.5" />
                <TextBox Name="txtDCBSMBPriority" Text="3" Width="50" Height="25" TextAlignment="Center" IsEnabled="false" Opacity="0.5"/>
                <TextBox Name="txtDCBSMBPolicy" Text="SMBDirect" Width="117" Height="25" Margin="15,2" IsEnabled="false" Opacity="0.5"/>
                <Label Content="" Margin="0,0,0,0" HorizontalAlignment="Left" Width="15"/>
                <ComboBox Name="cmbSMBTemplate" Width="64" IsEnabled="False" Opacity="0.5">
                    <ComboBoxItem IsSelected="True">None</ComboBoxItem>
                </ComboBox>
                <Label Content="" Margin="0,0,0,0" HorizontalAlignment="Left" Width="25"/>
                <TextBox Name="txtDCBSMBRDMAPort" Text="445" Width="80" Height="25" IsEnabled="False" Opacity="0.5" Margin="0,2" TextAlignment="Center"/>
                <Label Content="" Margin="0,0,0,0" HorizontalAlignment="Left" Width="21"/>
                <Label Content="" Margin="0,0,0,0" HorizontalAlignment="Left" Width="21"/>
                <TextBox Name="txtDCBSMBBandwidth" Text="50" Width="57" Height="25" TextAlignment="Center" IsEnabled="false" Opacity="0.5"/>
            </StackPanel>
            <StackPanel Orientation="Horizontal" Margin="5,2" Height="30">
                <CheckBox Name="chkDCBDefaultEnabled" Width="35" VerticalAlignment="Center" IsEnabled="false" IsChecked="false" Opacity="0.5" />
                <TextBox Name="txtDCBDefaultPriority" Text="0" Width="50" Height="25" TextAlignment="Center" IsEnabled="False" Opacity="0.5"/>
                <TextBox Name="txtDCBDefaultPolicy" Text="Default" Width="117" Height="25" Margin="15,2" IsEnabled="false" Opacity="0.5"/>
                <Label Content="" Margin="0,0,0,0" HorizontalAlignment="Left" Width="15"/>
                <ComboBox Name="cmbDefaultTemplate" Width="64" IsEnabled="False" Opacity="0.5">
                    <ComboBoxItem IsSelected="True">Default</ComboBoxItem>
                </ComboBox>
                <Label Content="" Margin="0,0,0,0" HorizontalAlignment="Left" Width="25"/>
                <TextBox Name="txtDCBDefaultRDMAPort" Text="N/A" Width="80" Height="25" IsEnabled="False" Opacity="0.5" Margin="0,2" TextAlignment="Center"/>
                <Label Content="" Margin="0,0,0,0" HorizontalAlignment="Left" Width="21"/>
                <Label Content="" Margin="0,0,0,0" HorizontalAlignment="Left" Width="21"/>
                <TextBox Name="txtDCBDefaultBandwidth" Text="49" Width="57" Height="25" TextAlignment="Center"  IsEnabled="false" Opacity="0.5"/>
            </StackPanel>
            <Separator></Separator>
            <StackPanel Orientation="Horizontal" Margin="464,2,0,2" Height="30">
                <TextBox Name="txtDCBTotalBandwidth" Text="100" Width="57" Height="25" TextAlignment="Center" IsEnabled="false" Opacity="0.5"/>
                <Label Content="Total" Margin="0,0,0,0" HorizontalAlignment="Left" Width="50"/>
            </StackPanel>
            <StackPanel Margin="0,20"/>
            <StackPanel Orientation="Horizontal" Margin="35,2">
                <TextBlock  Margin="0,0" TextWrapping="WrapWithOverflow" Width="544">
                    <Run Text="Note: " FontWeight="Bold"/><Run Text="PFC should not be enabled for the cluster policy "/><Run Text="on the fabric" FontWeight="Bold"/><Run Text=", however the ETS reservation should be configured."/>
                </TextBlock>
            </StackPanel>
        </StackPanel>
        <StackPanel Visibility="Visible" Name="panel6" HorizontalAlignment="Left" Height="522.101" VerticalAlignment="Top" Margin="169.149,0,0,0" Width="615.137">
            <Label Content="Save and Deploy" FontSize="18"  Margin="10,0"/>
            <TextBlock  Margin="14,0" TextWrapping="WrapWithOverflow">
                    <Run Text="In this section, you can save and optionally deploy the configuration you've created with this wizard.  Specify where you would like the file to be generated.  If you choose an existing file, it will be overwritten at the completion of this wizard."/>
            </TextBlock>
            <Grid Margin="0,5"/>
            <Separator></Separator>
            <StackPanel Orientation="Horizontal" Margin="0,2">
                <Grid Margin="0,7">
                    <Label Content="Configuration File Path: " Margin="10,0,0,0" HorizontalAlignment="Left" Width="140"/>
                    <TextBox Name="txtConfigFilePath" Text="" Margin="150,0,119.71,0" Width="300"></TextBox>
                    <Button Name="btnBrowse" Content="Browse..." Margin="0,0,10,0" HorizontalAlignment="Right" Width="104.71" Height="25.426" VerticalAlignment="Bottom"/>
                </Grid>
            </StackPanel>
            <Separator></Separator>
            <Grid Margin="0,10"/>
            <StackPanel Orientation="Horizontal" Margin="0,10">
                <Label Content="Deploy Configuration to Nodes: " Margin="10,0,0,0" HorizontalAlignment="Left" Width="180"/>
                <CheckBox Name="chkDeploy" Width="30" VerticalAlignment="Center" IsChecked="False" IsEnabled="True" />
            </StackPanel>
            <StackPanel Orientation="Horizontal" Margin="0,0">
                <Label Content="Azure Resource Group Name" Margin="50,0,0,0" HorizontalAlignment="Left" Width="184"/>
                <Label Content="Automation Account Name " Margin="40,0,0,0" HorizontalAlignment="Left" Width="159"/>
                <Label Content="Role Name" Margin="40,0,0,0" HorizontalAlignment="Left" Width="97"/>
            </StackPanel>
            <StackPanel Orientation="Horizontal" Margin="0,5">
                <TextBox Name="txtResourceGroupName" Text="" Margin="55,0,0,0" Width="170"></TextBox>
                <TextBox Name="txtAutomationAccountName" Text="" Margin="55,0,0,0" Width="165"></TextBox>
                <TextBox Name="txtAutomationRoleName" Text="" Margin="35,0,0,0" Width="109"></TextBox>
            </StackPanel>
            <StackPanel Orientation="Horizontal" Margin="0,5">
                <TextBlock Name="AzureWarning" Margin="81,0,10,0" TextWrapping="WrapWithOverflow" Width="383" Visibility="Hidden">
                    <Run Text="Warning: The Azure Resource Group and Automation Account will not be validated prior to running validation."/>
                </TextBlock>
            </StackPanel>
        </StackPanel>
        <StackPanel Visibility="Hidden" Name="panel9" HorizontalAlignment="Left" Height="522.101" VerticalAlignment="Top"  Margin="169.149,0,0,0" Width="615.137">
            <Label Content="Review" FontSize="18"  Margin="10,0"/>
            <TextBlock  Margin="14,0" TextWrapping="WrapWithOverflow"><Run Text="You have entered everything required for SDN Express to configure SDN on this system.  If you would like to save this configuration, select Export.  You can re-run SDN Express later with this file using the ConfigurationDataFile parameter."/></TextBlock>
            <Grid Margin="0,10"/>
            <TextBox Name="txtReview" Text="" Margin="14,0,0,0" Height="300" Template="{DynamicResource NormalTemplate}"/>
            <Grid Margin="0,5"/>
            <Button Name="btnExport" Content="Export..." Margin="0,0,14,0" HorizontalAlignment="Right" Width="153.868" Height="34.328" />
        </StackPanel>
        <Button Name="btnBack1" Content="Back" Margin="0,0,168.868,10" HorizontalAlignment="Right" Width="153.868" Height="34.328" VerticalAlignment="Bottom"/>
        <Button Name="btnNext1" Content="Next" Margin="0,0,10,10" HorizontalAlignment="Right" Width="153.868" Height="34.328" VerticalAlignment="Bottom"/>
        <Button Name="btnExportAndDeploy" Content="Export" Margin="0,0,10,10" HorizontalAlignment="Right" Width="153.868" Height="34.328" VerticalAlignment="Bottom" Visibility="Hidden" IsEnabled="False" />
    </Grid>
</Window>
'@

    function ValidateNotBlank {
        param (
            [Object] $ctl,
            [String] $message = "This field is required."
        )

        if ([String]::IsNullOrEmpty($ctl.text)) {
            $ctl.Template = $form.FindResource("ErrorTemplate")
            if ([String]::IsNullOrEmpty($ctl.Tooltip)) {
                $ctl.tooltip = "Invalid value: this field is required.`r`nDetail: $message"
            } 
            return $true 
        } else { 
            $ctl.tooltip = $message
            $ctl.Template = $global:defaulttxttemplate
            return $false
        }
    }
    
    function ValidateVLAN {
    param(
        [Object] $ctl
    )    
        if ([Regex]::Match($ctl.text, "^\d{1,4}$").Success) {
            $value = [Int32]::Parse($ctl.text)
            if ($value -le 4096 -and $value -ge 1) {
                $ctl.Template=$global:defaulttxttemplate
                $ctl.tooltip = ""
                return $false
            }
            $ctl.tooltip = "Invalid value: VLAN ID must be a value between 0 and 4096."
        } else {
            $ctl.tooltip = "Invalid value: VLAN ID can't contain non-numeric characters."
        }
        $ctl.Template=$form.FindResource("ErrorTemplate") 
        return $true
    }

    function Create-ConfigFile {
        # This function creates the configuration data and config file.
        #TODO: Won't need to create config data in the future - Currently just for testing

        $AllNodes    = @()
        $NonNodeData = @()

        '$AllNodes = @()' , "`$NonNodeData = @() `r`n" | Out-File $txtConfigFilePath.text

        #TODO: Currently automatically expands cluster names; in the future keep the cluster name and expand at runtime
        $Nodes = $SystemNames.items.SystemName

        $thisCount = 1
        $Nodes | Foreach-Object {
            $thisNode = $_
            
            if ($thisCount -eq $Nodes.Count) {
                $NodesConcat += "`'$thisNode`'"
            }
            Else {
                $NodesConcat += "`'$thisNode`' , "
            }

            $thisCount ++
        }
        
        $Nodes | ForEach-Object {
            $AllNodes   += @{ 
                NodeName = $_
            }
        }

        If ($chkDeploy.isChecked -eq $true) {
            0..($AllNodes.Count - 1) | ForEach-Object {
                $AllNodes[$_]   += @{ 
                    Role = $txtAutomationRoleName.text
                }
            }
        }

        if ( $cmbLBAlgorithm.text -ne 'Hyper-V Port') { $LBAlgorithm = 'Dynamic' }
        else { $LBAlgorithm = 'HyperVPort' }

        "`$Nodes = $NodesConcat `r`n", "`$Nodes | ForEach-Object {"  | Out-File $txtConfigFilePath.text -append
        "`t`$AllNodes   += @{", "`t`tNodeName = `$_`r`n"             | Out-File $txtConfigFilePath.text -append
        
        If ($chkDeploy.isChecked -eq $true) {
            "`t`tRole = `'$($txtAutomationRoleName.text)`'" | Out-File $txtConfigFilePath.text -append
        }
        
        If ($chkvSwAttached.isChecked -eq $true -and $_.Adapter.text -ne '') {
            "`t`tVMSwitch = @(" , "`t`t`t@{"      | Out-File $txtConfigFilePath.text -append
            "`t`t`t`tName = `'$($txtvSw1Name.text)`'" | Out-File $txtConfigFilePath.text -append
            "`t`t`t`tEmbeddedTeamingEnabled = `$$($chkvSw1TeamingEnabled.isChecked)" | Out-File $txtConfigFilePath.text -append
            "`t`t`t`tLoadBalancingAlgorithm = `'$LBAlgorithm`'`r" | Out-File $txtConfigFilePath.text -append
            "`t`t`t`tRDMAEnabledAdapters = @("                    | Out-File $txtConfigFilePath.text -append
        }
        else {
            "`t`tRDMAEnabledAdapters = @("                    | Out-File $txtConfigFilePath.text -append
        }

        @{ adapter = $txtAdpt1; vNIC = $txtvSw1vNIC1Name; VLAN = $txtAdpt1VLAN},
        @{ adapter = $txtAdpt2; vNIC = $txtvSw1vNIC2Name; VLAN = $txtAdpt2VLAN},
        @{ adapter = $txtAdpt3; vNIC = $txtvSw1vNIC3Name; VLAN = $txtAdpt3VLAN},
        @{ adapter = $txtAdpt4; vNIC = $txtvSw1vNIC4Name; VLAN = $txtAdpt4VLAN}  | ForEach-Object {
            If ($chkvSwAttached.isChecked -eq $true -and $_.Adapter.text -ne '') {
                $RDMAEnabledAdapters += @(
                    @{ Name = $_.Adapter.text ; VMNetworkAdapter = $_.vNIC.text ; VLANID = $_.VLAN.text ; JumboPacket = $cmbvSw1Jumbo.text }
                )

                "`t`t`t`t`t@{ Name = `'$($_.Adapter.text)`' ; VMNetworkAdapter = `'$($_.vNIC.text)`' ; VLANID = $($_.VLAN.text) ; JumboPacket = $($cmbvSw1Jumbo.text) }" | Out-File $txtConfigFilePath.text -append
                
            }
            ElseIf ($chkvSwAttached.isChecked -eq $false -and $_.Adapter.text -ne '') {
                $RDMAEnabledAdapters += @(
                    @{ Name = $_.Adapter.text ; VLANID = $_.VLAN.text ; JumboPacket = $cmbvSw1Jumbo.text }
                )
                
                "`t`t`t@{ Name = `'$($_.Adapter.text)`' ; VLANID = $($_.VLAN.text) ; JumboPacket = $($cmbvSw1Jumbo.text) }" | Out-File $txtConfigFilePath.text -append
            }
        }

        If ($chkvSwAttached.isChecked -eq $true -and $_.Adapter.text -ne '') { "`t`t`t`t)", "`t`t`t}", "`t`t)", "`t}", "}`r" | Out-File $txtConfigFilePath.text -append }
        else { "`t`t)", "`t}", "}`r" | Out-File $txtConfigFilePath.text -append }

        $vmSwitch = $txtvSw1Name.text
        $loadBalancingAlgorithm = $cmbLBAlgorithm.text

        If ($chkvSw1TeamingEnabled.isChecked = $true) {
            $EmbeddedTeamingEnabled = $true
        }
        Else {
            $EmbeddedTeamingEnabled = $False
        }

        #TODO: Add IovEnabled once the deployment is fixed
        If ($chkvSwAttached.isChecked -eq $true -and $_.Adapter.text -ne '') {
            0..($AllNodes.Count - 1) | foreach-Object {
                $thisNode = $_
                
                $AllNodes[$thisNode] += @{
                    VMSwitch = @(
                        @{
                            Name = $vmSwitch
                            EmbeddedTeamingEnabled = $EmbeddedTeamingEnabled
                            LoadBalancingAlgorithm = $loadBalancingAlgorithm
                            RDMAEnabledAdapters = @( $RDMAEnabledAdapters )
                        }
                    )
                }
            }
        }
        ElseIf ($chkvSwAttached.isChecked -eq $false -and $_.Adapter.text -ne '') {
            0..($AllNodes.Count - 1) | foreach-Object {
                $AllNodes[$_]   += @{
                    Name = $vmSwitch
                    EmbeddedTeamingEnabled = $EmbeddedTeamingEnabled
                    LoadBalancingAlgorithm = $loadBalancingAlgorithm
                    RDMAEnabledAdapters = @( $RDMAEnabledAdapters )
                }
            }
        }

        '$NonNodeData = @{', "`tNetQoS = @(" | Out-File $txtConfigFilePath.text -append

        If ($chkEnableDCB.isChecked) {
            if ($chkDCBClusterEnabled.isChecked -eq $true) {
                $policies += @(
                    @{ Name = $txtDCBClusterPolicy.text ; PriorityValue8021Action = $txtDCBClusterPriority.text ; Template = $cmbClusterTemplate.text ; BandwidthPercentage = $txtDCBClusterBandwidth.text }
                )

                "`t`t@{ Name = `'$($txtDCBClusterPolicy.text)`' ; PriorityValue8021Action = $($txtDCBClusterPriority.text) ; Template = `'$($cmbClusterTemplate.text)`' ; BandwidthPercentage = $($txtDCBClusterBandwidth.text) ; Algorithm = 'ETS' }" | Out-File $txtConfigFilePath.text -append
            }

            if ($chkDCBSMBEnabled.isChecked -eq $true) {
                $policies += @(
                    @{ Name = $txtDCBSMBPolicy.text ; PriorityValue8021Action = $txtDCBSMBPriority.text ; NetDirectPortMatchCondition = $txtDCBSMBRDMAPort.text ; BandwidthPercentage = $txtDCBSMBBandwidth.text }
                )

                "`t`t@{ Name = `'$($txtDCBSMBPolicy.text)`' ; PriorityValue8021Action = $($txtDCBSMBPriority.text) ; NetDirectPortMatchCondition = $($txtDCBSMBRDMAPort.text) ; BandwidthPercentage = $($txtDCBSMBBandwidth.text) ; Algorithm = 'ETS' }" | Out-File $txtConfigFilePath.text -append
            }

            if ($chkDCBDefaultEnabled.isChecked -eq $true) {
                $policies += @(
                    @{ Name = $txtDCBDefaultPolicy.text ; PriorityValue8021Action = $txtDCBDefaultPriority.text ; Template = $cmbDefaultTemplate.text ; BandwidthPercentage = $txtDCBDefaultBandwidth.text }
                )

                "`t`t@{ Name = `'$($txtDCBDefaultPolicy.text)`' ; PriorityValue8021Action = $($txtDCBDefaultPriority.text) ; Template = `'$($cmbDefaultTemplate.text)`' ; BandwidthPercentage = $($txtDCBDefaultBandwidth.text) ; Algorithm = 'ETS' }" | Out-File $txtConfigFilePath.text -append
            }

            $NonNodeData = @{
                NetQoS = @( $policies )
            }
        }

        "`t)" | Out-File $txtConfigFilePath.text -append

        if ($chkDeploy.isChecked) {
            $Automation += @(
                @{ ResourceGroupName = $txtResourceGroupName.text ; AutomationAccountName = $AutomationAccountName.text }
            )

            "`r`tAzureAutomation = @{"   | Out-File $txtConfigFilePath.text -append
            "`t`tResourceGroupName = `'$($txtResourceGroupName.text)`'"     | Out-File $txtConfigFilePath.text -append
            "`t`t`AutomationAccountName = `'$($txtAutomationAccountName.text)`'" | Out-File $txtConfigFilePath.text -append
            "`t}" | Out-File $txtConfigFilePath.text -append

            $NonNodeData += @{
                AzureAutomation = @( $Automation )
            }
        }

        "}" | Out-File $txtConfigFilePath.text -append
        
        $global:configData = @{
            AllNodes    = $AllNodes
            NonNodeData = $NonNodeData
        }

        "`r`$Global:configData = @{"       | Out-File $txtConfigFilePath.text -append
        "`tAllNodes    = `$AllNodes"       | Out-File $txtConfigFilePath.text -append
        "`tNonNodeData    = `$NonNodeData" | Out-File $txtConfigFilePath.text -append
        '}' | Out-File $txtConfigFilePath.text -append

        return $ConfigData
    }

    function ValidateConfigFile {
        param(
            [Object] $ctl,
            [String] $message = "This field is required."
        )
    
        $extension = $ctl.text.Split('.')[$ctl.text.Split('.').Count - 1]

        $leaf       = $ctl.text.Split('\')[$ctl.text.Split('\').Count - 1]
        
        if (($leaf) -and $leaf -ne $ctl.text) {
            $parentPath = $ctl.text -replace $leaf, $null
        }

        if ($parentPath) {
            $parentPathExists = Test-Path $parentPath
        }
    
        if ($extension -eq 'ps1' -and $parentPathExists -eq $true) {
            $ctl.tooltip = $message
            $ctl.Template = $global:defaulttxttemplate
            return $false
        }
        else {
            $ctl.Template = $form.FindResource("ErrorTemplate")
            if ([String]::IsNullOrEmpty($ctl.Tooltip)) {
                $ctl.tooltip = "Invalid value: this field is required.`r`nDetail: $message"
            } 
            return $true 
        }
    }
    function ValidateHostorCluster {
        param ( [Object] $ctl )

        $ClusterNodes = @()
        $Cluster = Get-ClusterNode -Cluster $ctl.text -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

        if ($ctl.text -eq (($Cluster.Cluster).Name | Select-Object -Unique)) {
            $Cluster | Foreach-Object {
                $global:Nodes = $_.Name

                $ClusterNodes += @{
                    NodeName    = $_.Name
                    ClusterName = $_.Cluster.Name
                }
            }

            $resolved = $ClusterNodes
        }
        else {
             #$DNSName = (Resolve-DnsName -Name $ctl.text | Select-Object -First 1).Name.Split('.')[0]
            
            $ClusterNodes += @{
                NodeName   = $ctl.text
                ClusterName = ''
            }

            $Resolved = $ClusterNodes
            $global:Nodes += $ClusterNodes.NodeName
        }

        return $resolved
    }

    function ValidateChkBoxwTxt {
        param ( 
            [Object] $CheckBox,
            [Object] $ctl, 
            [String] $message
        )

        if ($Checkbox.IsChecked -eq $true) {
            $vSwitchTxt += ValidateNotBlank $ctl
            
            if ($vSwitchTxt) {
                $ctl.tooltip = "This field is required.`r`nDetail: $message"
                $ctl.Template = $form.FindResource("ErrorTemplate")
                return $true
            }
            else {
                $ctl.Template = $global:defaulttxttemplate
                return $false
            }
        }
        else {
            $ctl.Template = $global:defaulttxttemplate
            return $false
        }
    }

    Function ClearDefaultObjText {
        param ( [Object] $ctl )

        $ctl.text = ''
    }

    Function SetDefaultObjText {
        param (
            [Object] $ctl,
            [String] $message
        )

        $ctl.text = $message
    }

    function ValidateChkBoxwCombo {
        param ( 
            [Object] $CheckBox,
            [Object] $ctl, 
            [String] $message
        )

        if ($Checkbox.IsChecked -eq $true) { $ctl.isEnabled = $true }
        else { $ctl.isEnabled = $false }
    }

    function ValidateDCBPriority {
        param ( 
            [uint16] $MinPriority,
            [uint16] $MaxPriority,
            [Object] $ctl
        )

        Try {
            [int] $value = $ctl.text

            if ($value -ge $MinPriority -and $value -le $MaxPriority) {
                $ctl.Template = $global:defaulttxttemplate
                return $false
            }
            else {
                $ctl.tooltip = "This field must specified a value between $MinPriority and $MaxPriority"
                $ctl.Template = $form.FindResource("ErrorTemplate")
                return $true
            }
        }
        catch {
            $ctl.tooltip = "This field must specified a value between $MinPriority and $MaxPriority"
            $ctl.Template = $form.FindResource("ErrorTemplate")
            return $true
        }
    }

    function ValidateNumberRange {
        param ( 
            [uint16] $RangeStart,
            [uint16] $RangeEnd,
            [Object] $ctl
        )

        Try {
            [int] $value = $ctl.text

            if ($value -lt $RangeStart -or $value -gt $RangeEnd) {
                $ctl.tooltip = "This field must specified a value between $RangeStart and $RangeEnd"
                $ctl.Template = $form.FindResource("ErrorTemplate")

                return $true
            }
            else {
                $ctl.Template = $global:defaulttxttemplate
                return $false
            }
        }
        catch {
            $ctl.tooltip = "This field must specified a value between $RangeStart and $RangeEnd"
            $ctl.Template = $form.FindResource("ErrorTemplate")
            return $true
        }
    }

    function Add-ReservationBandwidth {
        param ( 
            [Object[]] $ctl
        )

        $ctl | ForEach-Object {
            try {
                [uint16] $global:reservationTotal = $global:reservationTotal + $_.text
            }
            catch {
                $ctl.tooltip = "This field must specified a numeric value of 1"
                $ctl.Template = $form.FindResource("ErrorTemplate")
    
                $results += $true
            }
        }
    }

    function Set-PanelDCBEnabled {
        $chkDCBClusterEnabled.IsEnabled = $false
        $chkDCBSMBEnabled.IsEnabled     = $false
        $chkDCBDefaultEnabled.IsEnabled = $false

        $chkDCBClusterEnabled.IsChecked = $true
        $chkDCBSMBEnabled.IsChecked     = $true
        $chkDCBDefaultEnabled.IsChecked = $true

        $chkDCBClusterEnabled.Opacity = "0.5"
        $chkDCBSMBEnabled.Opacity     = "0.5"
        $chkDCBDefaultEnabled.Opacity = "0.5"

        $txtDCBClusterPriority.IsEnabled = $true
        $txtDCBSMBPriority.IsEnabled     = $true
        $txtDCBDefaultPriority.IsEnabled = $false

        $txtDCBClusterPriority.Opacity = "1"
        $txtDCBSMBPriority.Opacity     = "1"
        $txtDCBDefaultPriority.Opacity = "0.5"

        $txtDCBClusterPolicy.IsEnabled = $true
        $txtDCBSMBPolicy.IsEnabled     = $true
        $txtDCBDefaultPolicy.IsEnabled = $false

        $txtDCBClusterPolicy.Opacity = "1"
        $txtDCBSMBPolicy.Opacity     = "1"
        $txtDCBDefaultPolicy.Opacity = "0.5"

        $txtDCBClusterRDMAPort.IsEnabled = $false
        $txtDCBSMBRDMAPort.IsEnabled     = $false
        $txtDCBDefaultRDMAPort.IsEnabled = $false

        $txtDCBClusterRDMAPort.Opacity = "0.5"
        $txtDCBSMBRDMAPort.Opacity     = "0.5"
        $txtDCBDefaultRDMAPort.Opacity = "0.5"

        $txtDCBClusterBandwidth.Template = $global:defaulttxttemplate
        $txtDCBSMBBandwidth.Template     = $global:defaulttxttemplate
        $txtDCBDefaultBandwidth.Template = $global:defaulttxttemplate

        $txtDCBClusterBandwidth.IsEnabled = $false
        $txtDCBSMBBandwidth.IsEnabled     = $true
        $txtDCBDefaultBandwidth.IsEnabled = $false

        $txtDCBClusterBandwidth.Opacity = "0.5"
        $txtDCBSMBBandwidth.Opacity     = "1"
        $txtDCBDefaultBandwidth.Opacity = "0.5"
    }

    function Set-PanelDCBDisabled {
        $chkDCBClusterEnabled.IsEnabled = $false
        $chkDCBSMBEnabled.IsEnabled     = $false
        $chkDCBDefaultEnabled.IsEnabled = $false

        $chkDCBClusterEnabled.IsChecked = $false
        $chkDCBSMBEnabled.IsChecked     = $false
        $chkDCBDefaultEnabled.IsChecked = $false

        $chkDCBClusterEnabled.Opacity = "0.5"
        $chkDCBSMBEnabled.Opacity     = "0.5"
        $chkDCBDefaultEnabled.Opacity = "0.5"

        $txtDCBClusterPriority.Template = $global:defaulttxttemplate
        $txtDCBSMBPriority.Template     = $global:defaulttxttemplate
        $txtDCBDefaultPriority.Template = $global:defaulttxttemplate

        $txtDCBClusterPriority.IsEnabled = $false
        $txtDCBSMBPriority.IsEnabled     = $false
        $txtDCBDefaultPriority.IsEnabled = $false

        $txtDCBClusterPriority.Opacity = "0.5"
        $txtDCBSMBPriority.Opacity     = "0.5"
        $txtDCBDefaultPriority.Opacity = "0.5"

        SetDefaultObjText -Ctl $txtDCBClusterPriority -message '7'
        SetDefaultObjText -Ctl $txtDCBSMBPriority     -message '3'

        $txtDCBClusterPolicy.Template = $global:defaulttxttemplate
        $txtDCBSMBPolicy.Template     = $global:defaulttxttemplate
        $txtDCBDefaultPolicy.Template = $global:defaulttxttemplate

        $txtDCBClusterPolicy.IsEnabled = $false
        $txtDCBSMBPolicy.IsEnabled     = $false
        $txtDCBDefaultPolicy.IsEnabled = $false

        $txtDCBClusterPolicy.Opacity = "0.5"
        $txtDCBSMBPolicy.Opacity     = "0.5"
        $txtDCBDefaultPolicy.Opacity = "0.5"

        SetDefaultObjText -Ctl $txtDCBClusterPolicy -message 'Cluster'
        SetDefaultObjText -Ctl $txtDCBSMBPolicy     -message 'SMBDirect'

        $txtDCBClusterRDMAPort.Template = $global:defaulttxttemplate
        $txtDCBSMBRDMAPort.Template     = $global:defaulttxttemplate
        $txtDCBDefaultRDMAPort.Template = $global:defaulttxttemplate

        $txtDCBClusterRDMAPort.IsEnabled = $false
        $txtDCBSMBRDMAPort.IsEnabled     = $false
        $txtDCBDefaultRDMAPort.IsEnabled = $false

        $txtDCBClusterRDMAPort.Opacity = "0.5"
        $txtDCBSMBRDMAPort.Opacity     = "0.5"
        $txtDCBDefaultRDMAPort.Opacity = "0.5"

        SetDefaultObjText -Ctl $txtDCBClusterRDMAPort -message 'N/A'
        SetDefaultObjText -Ctl $txtDCBSMBRDMAPort     -message '445'

        

        $txtDCBClusterBandwidth.IsEnabled = $false
        $txtDCBSMBBandwidth.IsEnabled     = $false
        $txtDCBDefaultBandwidth.IsEnabled = $false

        $txtDCBClusterBandwidth.Opacity = "0.5"
        $txtDCBSMBBandwidth.Opacity     = "0.5"
        $txtDCBDefaultBandwidth.Opacity = "0.5"

        SetDefaultObjText -Ctl $txtDCBClusterBandwidth -message '1'
        SetDefaultObjText -Ctl $txtDCBSMBBandwidth     -message '50'
        SetDefaultObjText -Ctl $txtDCBSMBBandwidth     -message '49'
    }

    #TODO: ValidatePanel2 will be repurposed for an import page in the future.
    <#$ValidatePanel2 = {
        $results = @()
        $results += ValidateNotBlank   $txtConfigFilePath "This field must contain the path and filename of the configuration file to be generated."
        $results += ValidateConfigFile $txtConfigFilePath "This field must contain the path and filename of the configuration file to be generated."

        foreach ($result in $results) {
            if ($result) {
                $btnNext1.IsEnabled = $false
                return
            }
        }
        $btnNext1.IsEnabled = $true
    }#>

    $ValidatePanel3 = {
        $results = @()

        if ($SystemNames.items.count -ge 1) {
            $txtHostorCluster.Template=$global:defaulttxttemplate
        }
        else {
            $results += $true
        }

        foreach ($result in $results) {
            if ($result) {
                $btnNext1.IsEnabled = $false
                return
            }
        }

        $btnNext1.IsEnabled = $true
    }

    $ValidatePanel4 = {
        $results = @()
        $results += ValidateChkBoxwTxt -CheckBox $chkvSwAttached -ctl $txtvSw1Name
        $results += ValidateChkBoxwTxt -CheckBox $chkvSwAttached -ctl $txtvSw1vNIC1Name
        $results += ValidateNotBlank $txtAdpt1

        if ($chkvSwAttached.IsChecked -eq $false) {
            $txtvSw1Name.IsEnabled           = $false
            $chkvSw1TeamingEnabled.IsEnabled = $false
            $chkvSw1SRIOVEnabled.IsEnabled   = $false
            $cmbLBAlgorithm.IsEnabled        = $false

            $txtvSw1vNIC1Name.IsEnabled = $false
        } 
        ElseIf ($chkvSwAttached.IsChecked -eq $true) {
            $txtvSw1Name.IsEnabled           = $true
            $chkvSw1TeamingEnabled.IsEnabled = $true
            $chkvSw1SRIOVEnabled.IsEnabled   = $true
            $cmbLBAlgorithm.IsEnabled        = $true

            $txtvSw1vNIC1Name.IsEnabled      = $true

            #$txtvSw1vNIC1Name.Template=$form.FindResource("ErrorTemplate")
            $results += ValidateNotBlank $txtvSw1vNIC1Name

            if ($chkvSw1TeamingEnabled.IsChecked -eq $true) {
                <#
                $txtAdpt2.IsEnabled = $true
                $txtAdpt3.IsEnabled = $true
                $txtAdpt4.IsEnabled = $true
                #>
    
                $txtvSw1vNIC2Name.IsEnabled = $true
                $txtvSw1vNIC3Name.IsEnabled = $true
                $txtvSw1vNIC4Name.IsEnabled = $true
   <# 
                $txtAdpt2VLAN.IsEnabled = $true
                $txtAdpt3VLAN.IsEnabled = $true
                $txtAdpt4VLAN.IsEnabled = $true
    #>
                if ($txtAdpt2.text -ne '') {
                    $results += ValidateNotBlank $txtvSw1vNIC2Name

                    if ($chkvSw1RDMAEnabled.IsChecked -eq $true -and $cmbRDMAType.text -eq 'RoCE') {
                        ValidateVLAN -ctl $txtAdpt2VLAN
                    }
                }

                if ($txtAdpt3.text -ne '') {
                    $results += ValidateNotBlank $txtvSw1vNIC3Name

                    if ($chkvSw1RDMAEnabled.IsChecked -eq $true -and $cmbRDMAType.text -eq 'RoCE') {
                        ValidateVLAN -ctl $txtAdpt3VLAN
                    }
                }

                if ($txtAdpt4.text -ne '') {
                    $txtvSw1vNIC4Name.Template=$form.FindResource("ErrorTemplate")
                    $results += ValidateNotBlank $txtvSw1vNIC4Name

                    if ($chkvSw1RDMAEnabled.IsChecked -eq $true -and $cmbRDMAType.text -eq 'RoCE') {
                        ValidateVLAN -ctl $txtAdpt4VLAN
                    }
                }
            }
        }

        If ($txtAdpt1VLAN.text -ne '0' -or $chkvSw1RDMAEnabled.IsChecked -eq $false) {
            ValidateVLAN -ctl $txtAdpt1VLAN
        }
        ElseIf ($chkvSw1RDMAEnabled.IsChecked -eq $true -and $cmbRDMAType.text -eq 'RoCE') {
            ValidateVLAN -ctl $txtAdpt1VLAN
        }
        else {
            $txtAdpt1VLAN.Template=$global:defaulttxttemplate
        }
        
        ValidateNumberRange -ctl $txtvSw1EncapOverhead -RangeStart 0 -RangeEnd 160

        foreach ($result in $results) {
            if ($result) {
                $btnNext1.IsEnabled = $false
                return
            }
        }
        $btnNext1.IsEnabled = $true
    }

    $ValidatePanel5 = {
        $results = @()
        
        [uint16] $global:reservationTotal = 0
        [uint16] $global:DefaultReservation = 0

        if ($chkvSw1RDMAEnabled.IsChecked) {
            $lblRDMAEnabled.Content = 'True'
        }
        Else {
            $lblRDMAEnabled.Content = 'False'
        }

        if ($cmbRDMAType.isEnabled -eq $true -and $cmbRDMAType.text -eq 'RoCE') {
            $lblDCBRequired.Content = 'True'
            $lblRDMAType.Content = 'RoCE'

            $chkEnableDCB.isChecked = $true
            $chkEnableDCB.isEnabled = $false
            $chkEnableDCB.Opacity   = '0.5'
        }
        ElseIf ($cmbRDMAType.isEnabled -eq $true -and $cmbRDMAType.text -eq 'iWARP') {
            $lblRDMAType.Content = 'iWARP'
            $lblDCBRequired.Content = 'False'

            $chkEnableDCB.isChecked = $false
            $chkEnableDCB.isEnabled = $true
            $chkEnableDCB.Opacity   = '1'
        }
        Else {
            $lblRDMAType.Content = 'Not Selected'
            $lblDCBRequired.Content = 'False'

            $chkEnableDCB.isChecked = $false
            $chkEnableDCB.isEnabled = $true
            $chkEnableDCB.Opacity   = '1'
        }
        

        If ($chkDCBClusterEnabled.isChecked) {
            $results += ValidateDCBPriority -MinPriority 5 -MaxPriority 7 -Ctl $txtDCBClusterPriority
        }

        If ($chkDCBSMBEnabled.isChecked) {
            $results += ValidateNumberRange -RangeStart 10 -RangeEnd 99 -ctl $txtDCBSMBBandwidth
            $results += ValidateDCBPriority -MinPriority 3 -MaxPriority 4 -Ctl $txtDCBSMBPriority
        }

        foreach ($result in $results) {
            if ($result) {
                $btnNext1.IsEnabled = $false
                return
            }
        }

        $btnNext1.IsEnabled = $true
    }

    $ValidatePanel6 = {
        $results = @()

        if ($btnNext1.Visibility -eq 'Visible') { $btnNext1.Visibility = 'Hidden' }
        if ($btnExportAndDeploy.Visibility -eq 'Hidden') { $btnExportAndDeploy.Visibility = 'Visible' }

        $results += ValidateNotBlank   $txtConfigFilePath "This field must contain the path and filename of the configuration file to be generated."
        $results += ValidateConfigFile $txtConfigFilePath "This field must contain the path and filename of the configuration file to be generated."
        
        if ($chkDeploy.isChecked) {
            $results += ValidateNotBlank $txtAutomationAccountName "This field must contain the Azure Automation Account Name."
            $results += ValidateNotBlank $txtResourceGroupName "This field must contain the Azure Resource Group containing the Azure Automation Account Name."
            $results += ValidateNotBlank $txtAutomationRoleName "This field must contain the Azure Automation Account Name."

            $btnExportAndDeploy.Content = 'Export and Deploy'
        }

        foreach ($result in $results) {
            if ($result) {
                $btnNext1.IsEnabled = $false
                return
            }
        }

        $btnExportAndDeploy.IsEnabled = $true
    }

    function AddTxtValidation {
        param (
            $objtxt,
            $block
        )

        $objtxt.Add_TextChanged($block)
    }
    
    function Set-Panel {
        param( $PanelIndex )

        if ($panelIndex -eq 1) { $mark1.Visibility = "Visible"; $panel1.Visibility = "Visible"; } else { $mark1.Visibility = "Hidden"; $panel1.Visibility = "Hidden" }
        if ($panelIndex -eq 2) { 
            #Temporary
            $global:panelIndex = 3
            Set-Panel -PanelIndex $global:panelIndex
            
            
            #$mark2.Visibility = "Visible"; $panel2.Visibility = "Visible";  invoke-command $ValidatePanel2
        } 
        #else { $mark2.Visibility = "Hidden"; $panel2.Visibility = "Hidden" }

        if ($panelIndex -eq 3) { $mark3.Visibility = "Visible"; $panel3.Visibility = "Visible";  invoke-command $ValidatePanel3 } else { $mark3.Visibility = "Hidden"; $panel3.Visibility = "Hidden" }
        if ($panelIndex -eq 4) { $mark4.Visibility = "Visible"; $panel4.Visibility = "Visible";  invoke-command $ValidatePanel4 } else { $mark4.Visibility = "Hidden"; $panel4.Visibility = "Hidden" }
        if ($panelIndex -eq 5) { $mark5.Visibility = "Visible"; $panel5.Visibility = "Visible";  invoke-command $ValidatePanel5 } else { $mark5.Visibility = "Hidden"; $panel5.Visibility = "Hidden" }
        if ($panelIndex -eq 6) { $mark6.Visibility = "Visible"; $panel6.Visibility = "Visible";  invoke-command $ValidatePanel6 } else { $mark6.Visibility = "Hidden"; $panel6.Visibility = "Hidden" }
        
        <#if ($panelIndex -eq 9) { 
            $mark9.Visibility = "Visible"; 
            $panel9.Visibility = "Visible"; 
            $btnNext1.Content = "Deploy"
            $txtReview.Text =  ConfigDataToString (GenerateConfigData)
        } 
        else { 
            $mark9.Visibility = "Hidden"; 
            $panel9.Visibility = "Hidden"; 
            $btnNext1.Content = "Next"
        }
        #>

        #if ($panelIndex -eq 10) { $global:Deploy = $true; $form.Close() }
    }

#region Main
    #Read XAML
    $reader=(New-Object System.Xml.XmlNodeReader $xaml)

    try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
    catch{Write-Host "Unable to load Windows.Markup.XamlReader. Some possible causes for this problem include: .NET Framework is missing PowerShell must be launched with PowerShell -sta, invalid XAML code was encountered."; exit}

    $xaml.SelectNodes("//*[@Name]") | ForEach-Object {
        Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)
    }

    $global:Nodes = @()
    $global:PanelIndex = 1
    $global:Deploy = $false
    $global:defaulttxttemplate = $form.FindResource("NormalTemplate")

    $btnBack1.IsEnabled = $false

    $uri1.Add_Click({ Start-Process -FilePath $this.NavigateUri})
    $uri2.Add_Click({ Start-Process -FilePath $this.NavigateUri})
    $uri3.Add_Click({ Start-Process -FilePath $this.NavigateUri})
    
    $btnBack1.Add_Click({
        $global:PanelIndex=$global:panelIndex - 1;

        # Temporary till Panel2 is added
        If ($global:PanelIndex -eq 2) {
            $global:PanelIndex=$global:panelIndex - 1;
        }
        
        Set-Panel -PanelIndex $global:panelIndex;
                
        if ($global:panelIndex -eq 1) { 
            $btnBack1.IsEnabled = $false
        }
    })

    $btnNext1.Add_Click({
        $global:PanelIndex=$global:panelIndex + 1;

        # Temporary till Panel2 is added
        If ($global:PanelIndex -eq 2) {
            $global:PanelIndex=$global:panelIndex + 1;
        }

        Set-Panel -PanelIndex $global:panelIndex;

        if ($global:panelIndex -gt 1) {
            $btnBack1.IsEnabled = $true
        }
    })
    
    $chkvSwAttached.Add_Checked({
        ValidateChkBoxwTxt -CheckBox $chkvSwAttached -ctl $txtvSw1Name
        ValidateChkBoxwTxt -CheckBox $chkvSwAttached -ctl $txtvSw1vNIC1Name

        $txtvSw1Name.IsEnabled = $true
        $chkvSw1TeamingEnabled.IsEnabled = $true
        $chkvSw1SRIOVEnabled.IsEnabled = $true
        $cmbLBAlgorithm.IsEnabled = $true
        $txtvSw1vNIC1Name.IsEnabled = $true

        $txtvSw1Name.Opacity = "1"
        $chkvSw1TeamingEnabled.Opacity = "1"        
        $chkvSw1SRIOVEnabled.Opacity = "1"
        $cmbLBAlgorithm.Opacity = "1"
        $txtvSw1vNIC1Name.Opacity = "1"

        ClearDefaultObjText -Ctl $txtvSw1Name
        ClearDefaultObjText -Ctl $txtvSw1vNIC1Name

        if ($chkvSw1TeamingEnabled.IsChecked -eq $true) {
            $txtAdpt2.IsEnabled = $true
            $txtAdpt3.IsEnabled = $true
            $txtAdpt4.IsEnabled = $true

            $txtAdpt2.Opacity = "1"
            $txtAdpt3.Opacity = "1"
            $txtAdpt4.Opacity = "1"

            $txtvSw1vNIC1Name.IsEnabled = $true
            $txtvSw1vNIC2Name.IsEnabled = $true
            $txtvSw1vNIC3Name.IsEnabled = $true
            $txtvSw1vNIC4Name.IsEnabled = $true

            $txtvSw1vNIC1Name.Opacity = "1"
            $txtvSw1vNIC2Name.Opacity = "1"
            $txtvSw1vNIC3Name.Opacity = "1"
            $txtvSw1vNIC4Name.Opacity = "1"

            $txtAdpt2VLAN.IsEnabled = $true
            $txtAdpt3VLAN.IsEnabled = $true
            $txtAdpt4VLAN.IsEnabled = $true

            $txtAdpt2VLAN.Opacity = "1"
            $txtAdpt3VLAN.Opacity = "1"
            $txtAdpt4VLAN.Opacity = "1"

            ClearDefaultObjText -Ctl $txtAdpt2
            ClearDefaultObjText -Ctl $txtAdpt3
            ClearDefaultObjText -Ctl $txtAdpt4                

		    ClearDefaultObjText -Ctl $txtvSw1vNIC2Name
            ClearDefaultObjText -Ctl $txtvSw1vNIC3Name
            ClearDefaultObjText -Ctl $txtvSw1vNIC4Name
                
    		ClearDefaultObjText -Ctl $txtAdpt2VLAN
            ClearDefaultObjText -Ctl $txtAdpt3VLAN
            ClearDefaultObjText -Ctl $txtAdpt4VLAN
        }
    })

    $chkvSwAttached.Add_Unchecked({
        ValidateChkBoxwTxt -CheckBox $chkvSwAttached -ctl $txtvSw1Name
        ValidateChkBoxwTxt -CheckBox $chkvSwAttached -ctl $txtvSw1vNIC1Name

        SetDefaultObjText -Ctl $txtvSw1Name -message 'Enable vSwitch'

        $txtvSw1Name.Opacity = "0.5"
        $chkvSw1TeamingEnabled.Opacity = "0.5"
        $chkvSw1SRIOVEnabled.Opacity = "0.5"
        $cmbLBAlgorithm.Opacity = "0.5"

        $txtvSw1Name.IsEnabled = $false
        $chkvSw1TeamingEnabled.IsEnabled = $false
        $chkvSw1SRIOVEnabled.IsEnabled = $false
        $cmbLBAlgorithm.IsEnabled = $false
        
        $txtAdpt2.Opacity = "0.5"
        $txtAdpt3.Opacity = "0.5"
        $txtAdpt4.Opacity = "0.5"

        $txtAdpt2.IsEnabled = $false
        $txtAdpt3.IsEnabled = $false
        $txtAdpt4.IsEnabled = $false

        SetDefaultObjText -Ctl $txtvSw1vNIC1Name -message 'Enable vSwitch or Team'
        SetDefaultObjText -Ctl $txtvSw1vNIC2Name -message 'Enable vSwitch or Team'
        SetDefaultObjText -Ctl $txtvSw1vNIC3Name -message 'Enable vSwitch or Team'
        SetDefaultObjText -Ctl $txtvSw1vNIC4Name -message 'Enable vSwitch or Team'

        $txtvSw1vNIC1Name.Opacity = "0.5"
        $txtvSw1vNIC2Name.Opacity = "0.5"
        $txtvSw1vNIC3Name.Opacity = "0.5"
        $txtvSw1vNIC4Name.Opacity = "0.5"

        $txtvSw1vNIC1Name.IsEnabled = $false
        $txtvSw1vNIC2Name.IsEnabled = $false
        $txtvSw1vNIC3Name.IsEnabled = $false
        $txtvSw1vNIC4Name.IsEnabled = $false

        SetDefaultObjText -Ctl $txtAdpt2VLAN -message 'N/A'
        SetDefaultObjText -Ctl $txtAdpt3VLAN -message 'N/A'
        SetDefaultObjText -Ctl $txtAdpt4VLAN -message 'N/A'

        $txtAdpt2VLAN.Opacity = "0.5"
        $txtAdpt3VLAN.Opacity = "0.5"
        $txtAdpt4VLAN.Opacity = "0.5"

        $txtAdpt2VLAN.IsEnabled = $false
        $txtAdpt3VLAN.IsEnabled = $false
        $txtAdpt4VLAN.IsEnabled = $false

        $txtvSw1vNIC2Name.IsEnabled = $global:defaulttxttemplate
        $txtvSw1vNIC3Name.IsEnabled = $global:defaulttxttemplate
        $txtvSw1vNIC4Name.IsEnabled = $global:defaulttxttemplate

        $txtAdpt2VLAN.Template = $global:defaulttxttemplate
        $txtAdpt3VLAN.Template = $global:defaulttxttemplate
        $txtAdpt4VLAN.Template = $global:defaulttxttemplate

        if ($cmbRDMAType.text -eq 'RoCE') {
            $txtAdpt1VLAN.Template = $form.FindResource("ErrorTemplate")
        }
    })

    $chkvSw1TeamingEnabled.Add_Checked({
        $txtAdpt2.IsEnabled = $true
        $txtAdpt3.IsEnabled = $true
        $txtAdpt4.IsEnabled = $true

        $txtAdpt2.Opacity = "1"
        $txtAdpt3.Opacity = "1"
        $txtAdpt4.Opacity = "1"

        $txtvSw1vNIC2Name.IsEnabled = $true
        $txtvSw1vNIC3Name.IsEnabled = $true
        $txtvSw1vNIC4Name.IsEnabled = $true

        $txtvSw1vNIC2Name.Opacity = "1"
        $txtvSw1vNIC3Name.Opacity = "1"
        $txtvSw1vNIC4Name.Opacity = "1"

        $txtAdpt2VLAN.IsEnabled = $true
        $txtAdpt3VLAN.IsEnabled = $true
        $txtAdpt4VLAN.IsEnabled = $true

        $txtAdpt2VLAN.Opacity = "1"
        $txtAdpt3VLAN.Opacity = "1"
        $txtAdpt4VLAN.Opacity = "1"

        ClearDefaultObjText -Ctl $txtAdpt2
        ClearDefaultObjText -Ctl $txtAdpt3
        ClearDefaultObjText -Ctl $txtAdpt4                

        ClearDefaultObjText -Ctl $txtvSw1vNIC2Name
        ClearDefaultObjText -Ctl $txtvSw1vNIC3Name
        ClearDefaultObjText -Ctl $txtvSw1vNIC4Name
            
        ClearDefaultObjText -Ctl $txtAdpt2VLAN
        ClearDefaultObjText -Ctl $txtAdpt3VLAN
        ClearDefaultObjText -Ctl $txtAdpt4VLAN
    })

    $chkvSw1TeamingEnabled.Add_Unchecked({
        $txtAdpt2.IsEnabled = $false
        $txtAdpt3.IsEnabled = $false
        $txtAdpt4.IsEnabled = $false

        $txtAdpt2.Opacity = "0.5"
        $txtAdpt3.Opacity = "0.5"
        $txtAdpt4.Opacity = "0.5"

        $txtvSw1vNIC2Name.IsEnabled = $false
        $txtvSw1vNIC3Name.IsEnabled = $false
        $txtvSw1vNIC4Name.IsEnabled = $false

        $txtvSw1vNIC2Name.Opacity = "0.5"
        $txtvSw1vNIC3Name.Opacity = "0.5"
        $txtvSw1vNIC4Name.Opacity = "0.5"

        $txtAdpt2VLAN.IsEnabled = $false
        $txtAdpt3VLAN.IsEnabled = $false
        $txtAdpt4VLAN.IsEnabled = $false

        $txtAdpt2VLAN.Opacity = "0.5"
        $txtAdpt3VLAN.Opacity = "0.5"
        $txtAdpt4VLAN.Opacity = "0.5"

        SetDefaultObjText -Ctl $txtvSw1vNIC2Name -message 'Enable vSwitch or Team'
        SetDefaultObjText -Ctl $txtvSw1vNIC3Name -message 'Enable vSwitch or Team'
        SetDefaultObjText -Ctl $txtvSw1vNIC4Name -message 'Enable vSwitch or Team'
            
        SetDefaultObjText -Ctl $txtAdpt2VLAN -message 'N/A'
        SetDefaultObjText -Ctl $txtAdpt3VLAN -message 'N/A'
        SetDefaultObjText -Ctl $txtAdpt4VLAN -message 'N/A'
    })

    $chkvSw1RDMAEnabled.Add_Checked({
        ValidateChkBoxwCombo -CheckBox $chkvSw1RDMAEnabled -ctl $cmbRDMAType

        if ($cmbRDMAType.text -eq 'RoCE') {
            ValidateVLAN -ctl $txtAdpt1VLAN
        }
    })

    $chkvSw1RDMAEnabled.Add_Unchecked({
        ValidateChkBoxwCombo -CheckBox $chkvSw1RDMAEnabled -ctl $cmbRDMAType

        $txtAdpt1VLAN.Template = $global:defaulttxttemplate
        $txtAdpt2VLAN.Template = $global:defaulttxttemplate
        $txtAdpt3VLAN.Template = $global:defaulttxttemplate
        $txtAdpt4VLAN.Template = $global:defaulttxttemplate
    })

    $chkEnableDCB.Add_Checked({
        Set-PanelDCBEnabled
    })

    $chkEnableDCB.Add_Unchecked({
        Set-PanelDCBDisabled
    })

    $cmbRDMAType.Add_DropDownClosed({
        if ($cmbRDMAType.text -eq 'RoCE') {
            ValidateVLAN -ctl $txtAdpt1VLAN
        }

        if ($chkvSwAttached.IsChecked -eq $true -and $cmbRDMAType.text -eq 'RoCE' -and $txtAdpt2.text -ne '') {
            ValidateVLAN -ctl $txtAdpt2VLAN
        }

        if ($chkvSwAttached.IsChecked -eq $true -and $cmbRDMAType.text -eq 'RoCE' -and $txtAdpt3.text -ne '') {
            ValidateVLAN -ctl $txtAdpt3VLAN
        }

        if ($chkvSwAttached.IsChecked -eq $true -and $cmbRDMAType.text -eq 'RoCE' -and $txtAdpt4.text -ne '') {
            ValidateVLAN -ctl $txtAdpt4VLAN
        }

        if ($cmbRDMAType.text -eq 'iWARP') {
            $txtAdpt1VLAN.Template = $global:defaulttxttemplate
            $txtAdpt2VLAN.Template = $global:defaulttxttemplate
            $txtAdpt3VLAN.Template = $global:defaulttxttemplate
            $txtAdpt4VLAN.Template = $global:defaulttxttemplate
        }
    })

    $btnBrowse.Add_Click({
        [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

        $ofd = New-Object System.Windows.Forms.OpenFileDialog
        $ofd.initialDirectory = $txtVHDLocation.text
        $ofd.filter = "PowerShell Files (*.ps1)|*.ps1"
        $ofd.ShowDialog() | Out-Null
        $txtConfigFilePath.text = $ofd.Filename
    })

    $btnResolveHostorCluster.Add_Click({
        $resolved = ValidateHostorCluster $txtHostorCluster

        if ($resolved) {
            $txtHostorCluster.text = ''
        }        
        
        #TODO: Don't allow adding of duplicates
        #TODO: Add remove button
        #TODO: Add status text box that states please wait while resolving systems, or duplicate entry, etc.

        $resolved | ForEach-Object {
            if (!($_.Nodename -in $SystemNames.Items.SystemName)) {
                $SystemNames.items.Add(
                    [pscustomobject] @{
                        SystemName  = $_.NodeName
                        ClusterName = $_.ClusterName
                    }
                )
            }
        }

        invoke-command $ValidatePanel3
    })

    $btnExportAndDeploy.Add_Click({
        $global:ConfigPath = $txtConfigFilePath.text
        
        Create-ConfigFile

        If ($chkDeploy.IsChecked -eq $true) {
            $global:deploy = $true
        }

        $Form.Close()
    })

    $txtDCBClusterBandwidth.Add_TextChanged({
        try {
            $global:DefaultReservation = (100 - ([uint16] $txtDCBClusterBandwidth.text + [uint16] $txtDCBSMBBandwidth.text))
        }
        Catch {
            Write-Debug 'Invalid Arg in txtDCBClusterBandwidth'
        }
        
        $txtDCBDefaultBandwidth.text = $global:DefaultReservation
    })

    $txtDCBSMBBandwidth.Add_TextChanged({
        try {
            $global:DefaultReservation = (100 - ([uint16] $txtDCBClusterBandwidth.text + [uint16] $txtDCBSMBBandwidth.text))
        }
        Catch {
            Write-Debug 'Invalid Arg in txtDCBSMBBandwidth'
        }
        
        $txtDCBDefaultBandwidth.text = $global:DefaultReservation
    })

    $txtDCBDefaultBandwidth.Add_TextChanged({
        Add-ReservationBandwidth -Ctl $txtDCBClusterBandwidth, $txtDCBSMBBandwidth, $txtDCBDefaultBandwidth

        $txtDCBTotalBandwidth.text = $global:reservationTotal
    })

    $txtDCBTotalBandwidth.Add_TextChanged({
        ValidateNumberRange -RangeStart 100 -RangeEnd 100 -ctl $txtDCBTotalBandwidth
    })

    $chkDeploy.Add_Checked({
        $AzureWarning.Visibility="Visible"
        $btnExportAndDeploy.IsEnabled = $false

        Invoke-Command $ValidatePanel6
    })

    $chkDeploy.Add_UnChecked({
        $AzureWarning.Visibility="Hidden"

        $txtResourceGroupName.Template = $global:defaulttxttemplate
        $txtAutomationAccountName.Template = $global:defaulttxttemplate
        txtAutomationRoleName.Template = $global:defaulttxttemplate
    })

    # Panel 4 Text Validation
    AddTxtValidation $txtvSw1Name $ValidatePanel4

    AddTxtValidation $txtAdpt1 $ValidatePanel4
    AddTxtValidation $txtAdpt2 $ValidatePanel4
    AddTxtValidation $txtAdpt3 $ValidatePanel4
    AddTxtValidation $txtAdpt4 $ValidatePanel4

    AddTxtValidation $txtvSw1vNIC1Name $ValidatePanel4
    AddTxtValidation $txtvSw1vNIC2Name $ValidatePanel4
    AddTxtValidation $txtvSw1vNIC3Name $ValidatePanel4
    AddTxtValidation $txtvSw1vNIC4Name $ValidatePanel4

    AddTxtValidation $txtAdpt1VLAN $ValidatePanel4
    AddTxtValidation $txtAdpt2VLAN $ValidatePanel4
    AddTxtValidation $txtAdpt3VLAN $ValidatePanel4
    AddTxtValidation $txtAdpt4VLAN $ValidatePanel4
    AddTxtValidation $txtvSw1EncapOverhead $ValidatePanel4

    $txtAdpt2.Template=$global:defaulttxttemplate
    $txtAdpt3.Template=$global:defaulttxttemplate
    $txtAdpt4.Template=$global:defaulttxttemplate

    $txtvSw1vNIC1Name.Template=$global:defaulttxttemplate
    $txtvSw1vNIC2Name.Template=$global:defaulttxttemplate
    $txtvSw1vNIC3Name.Template=$global:defaulttxttemplate
    $txtvSw1vNIC4Name.Template=$global:defaulttxttemplate

    $txtAdpt1VLAN.Template=$global:defaulttxttemplate
    $txtAdpt2VLAN.Template=$global:defaulttxttemplate
    $txtAdpt3VLAN.Template=$global:defaulttxttemplate
    $txtAdpt4VLAN.Template=$global:defaulttxttemplate

    $txtvSw1EncapOverhead.Template=$global:defaulttxttemplate

    #Panel5
    AddTxtValidation $txtDCBClusterPriority $ValidatePanel5
    AddTxtValidation $txtDCBSMBPriority $ValidatePanel5

    AddTxtValidation $txtDCBClusterRDMAPort  $ValidatePanel5
    AddTxtValidation $txtDCBSMBRDMAPort      $ValidatePanel5

    AddTxtValidation $txtDCBClusterBandwidth $ValidatePanel5
    AddTxtValidation $txtDCBSMBBandwidth     $ValidatePanel5
    AddTxtValidation $txtDCBDefaultBandwidth $ValidatePanel5
    AddTxtValidation $txtDCBTotalBandwidth   $ValidatePanel5

    $txtDCBClusterPriority.Template  = $global:defaulttxttemplate
    $txtDCBClusterPolicy.Template    = $global:defaulttxttemplate
    $txtDCBClusterRDMAPort.Template  = $global:defaulttxttemplate
    $txtDCBClusterBandwidth.Template = $global:defaulttxttemplate

    $txtDCBSMBPriority.Template  = $global:defaulttxttemplate
    $txtDCBSMBPolicy.Template    = $global:defaulttxttemplate
    $txtDCBSMBRDMAPort.Template  = $global:defaulttxttemplate
    $txtDCBSMBBandwidth.Template = $global:defaulttxttemplate

    $txtDCBDefaultPriority.Template  = $global:defaulttxttemplate
    $txtDCBDefaultPolicy.Template    = $global:defaulttxttemplate
    $txtDCBDefaultRDMAPort.Template  = $global:defaulttxttemplate
    $txtDCBDefaultBandwidth.Template = $global:defaulttxttemplate

    $txtDCBTotalBandwidth.Template = $global:defaulttxttemplate

    #Panel6
    AddTxtValidation $txtConfigFilePath        $ValidatePanel6
    AddTxtValidation $txtAutomationAccountName $ValidatePanel6
    AddTxtValidation $txtResourceGroupName     $ValidatePanel6
    AddTxtValidation $txtAutomationRoleName    $ValidatePanel6

    $txtAutomationAccountName.Template  = $global:defaulttxttemplate
    $txtResourceGroupName.Template      = $global:defaulttxttemplate
    $txtAutomationRoleName.Template      = $global:defaulttxttemplate
    
    Set-Panel -PanelIndex $PanelIndex

    $Form.ShowDialog() | out-null
#endregion Main
}

#TODO: Panel4 no duplicate adapter names
#TODO: Panel4 no duplicate vNICs
#TODO: Panel4 Check then uncheck vSwitch should set vNIC and VLAN back to default template
#TODO: Panel5 Integrate Live Migration Bandwidth Limitation
#TODO: Import configuration on Panel2
#TODO: If you go back to the intro page, Next is not enabled
